resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-db-subnets"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.project}-db-subnets" })
}

resource "aws_security_group" "db" {
  name        = "${var.project}-db-sg"
  description = "RDS Postgres: reachable only from allowed SGs"
  vpc_id      = var.vpc_id

  # One ingress rule per allowed SG (dynamic). No CIDR, never public.
  dynamic "ingress" {
    for_each = toset(var.allowed_security_group_ids)
    content {
      description     = "Postgres from allowed SG"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-db-sg" })
}

resource "aws_db_instance" "this" {
  identifier     = "${var.project}-postgres"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.allocated_storage * 3
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username
  password = var.password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  # --- Optional backups (functions/conditionals) ---
  backup_retention_period   = var.enable_backups ? var.backup_retention_days : 0
  skip_final_snapshot       = !var.enable_backups
  final_snapshot_identifier = var.enable_backups ? "${var.project}-postgres-final" : null
  deletion_protection       = var.enable_backups

  tags = merge(var.tags, { Name = "${var.project}-postgres" })
}
