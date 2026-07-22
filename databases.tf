# Create BOTH per-app databases (+ login roles) inside the single RDS instance.
#
# RDS is private, so this can't be done from a laptop directly. Instead we hop
# through the app EC2 (which sits in the app SG the DB allows) and run psql from
# a postgres container against RDS. Idempotent — safe to re-run.
#
# Gated by manage_databases. Requires create_key_pair = true (uses the generated
# key to SSH the app box).

resource "null_resource" "databases" {
  count = var.manage_databases ? 1 : 0

  depends_on = [module.database, module.compute]

  # Re-run if any name/password changes.
  triggers = {
    spec = sha256(join(",", [
      var.app1_db_name, var.app1_db_user,
      var.app2_db_name, var.app2_db_user,
      var.app1_db_password, var.app2_db_password,
    ]))
  }

  connection {
    type        = "ssh"
    host        = module.compute.public_ips["app"]
    user        = "ubuntu"
    private_key = file("${path.root}/${var.project}-key.pem")
    timeout     = "3m"
  }

  provisioner "file" {
    destination = "/tmp/create_databases.sh"
    content = templatefile("${path.module}/scripts/create_databases.sh.tftpl", {
      rds_host        = module.database.address
      master_user     = var.master_username
      master_password = var.master_password
      init_db         = var.app1_db_name
      app1_db         = var.app1_db_name
      app1_user       = var.app1_db_user
      app1_password   = var.app1_db_password
      app2_db         = var.app2_db_name
      app2_user       = var.app2_db_user
      app2_password   = var.app2_db_password
    })
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/create_databases.sh",
      "rm -f /tmp/create_databases.sh",
    ]
  }
}
