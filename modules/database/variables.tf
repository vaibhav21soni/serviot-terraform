variable "project" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }

# SGs allowed to reach Postgres (the app instance). Expanded via dynamic block.
variable "allowed_security_group_ids" {
  type = list(string)
}

variable "instance_class" {
  type    = string
  default = "db.t3.small"
}
variable "allocated_storage" {
  type    = number
  default = 20
}
variable "engine_version" {
  type    = string
  default = "16.4"
}

variable "db_name" { type = string }
variable "username" { type = string }
variable "password" {
  type      = string
  sensitive = true
}

# Backups are OPTIONAL. When false: retention 0, no final snapshot, deletion
# protection off (so a demo teardown is one command). Turn on for prod.
variable "enable_backups" {
  type    = bool
  default = false
}
variable "backup_retention_days" {
  type    = number
  default = 7
}
variable "multi_az" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
