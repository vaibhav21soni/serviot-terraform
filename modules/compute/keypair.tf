# Key pair for SSH. When create_key_pair is true (default) Terraform generates
# an ED25519 key, registers the public half with AWS, and writes the private
# half to <root>/<project>-key.pem (0400, gitignored). Set create_key_pair
# false to use a pre-existing key named var.existing_key_name instead.

resource "tls_private_key" "this" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = "ED25519"
}

resource "aws_key_pair" "this" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "${var.project}-key"
  public_key = tls_private_key.this[0].public_key_openssh
  tags       = var.tags
}

resource "local_sensitive_file" "private_key" {
  count           = var.create_key_pair ? 1 : 0
  content         = tls_private_key.this[0].private_key_openssh
  filename        = "${path.root}/${var.project}-key.pem"
  file_permission = "0400"
}

locals {
  # The key name instances actually launch with.
  key_name = var.create_key_pair ? aws_key_pair.this[0].key_name : var.existing_key_name
}
