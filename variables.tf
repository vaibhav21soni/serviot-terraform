variable "project" {
  type    = string
  default = "serviot"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# ---- Networking ----
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "azs" {
  description = "Two AZs — RDS subnet group requires >= 2. Subnet CIDRs are derived from vpc_cidr."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# CRITICAL: SSH + Jenkins are locked to this CIDR, never 0.0.0.0/0. No default
# on purpose — a world-open admin port is a finding. Use a /32.
variable "admin_ip_cidr" {
  description = "CIDR allowed to reach SSH (22) and the Jenkins port."
  type        = string
}

# ---- Instances (driven by for_each in the compute module) ----
variable "instances" {
  description = "EC2 instances to create, keyed by name. One app box, one Jenkins box."
  type = map(object({
    role          = string
    instance_type = string
    root_gb       = optional(number, 30)
  }))
  default = {
    app = {
      role          = "app"
      instance_type = "t3.medium"
    }
    jenkins = {
      role          = "jenkins"
      instance_type = "t3.small"
    }
  }
}

# Key pair: generate one (default) or reuse an existing key by name.
variable "create_key_pair" {
  description = "Generate an EC2 key pair and write the private key locally."
  type        = bool
  default     = true
}
variable "existing_key_name" {
  description = "Existing EC2 key pair name. Used only when create_key_pair = false."
  type        = string
  default     = ""
}

variable "jenkins_port" {
  description = "Non-default Jenkins port (NOT 8080)."
  type        = number
  default     = 8443
}

# CIDRs allowed to reach the Jenkins UI. Defaults to the world per request.
# SECURITY: narrow this to your IP(s) in prod — public Jenkins is a prime
# target. SSH stays admin-only regardless.
variable "jenkins_ingress_cidrs" {
  description = "CIDRs allowed to reach the Jenkins UI port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---- Database (RDS Postgres) ----
variable "db_instance_class" {
  type    = string
  default = "db.t3.small"
}
variable "db_allocated_storage" {
  type    = number
  default = 20
}
variable "db_engine_version" {
  type    = string
  default = "16.4"
}

variable "master_username" {
  type    = string
  default = "serviot_admin"
}
variable "master_password" {
  description = "RDS master password. Pass via TF_VAR_master_password, never commit."
  type        = string
  sensitive   = true
}

# Backups are OFF by default (optional). Turn on for prod.
variable "enable_backups" {
  description = "Enable RDS automated backups, final snapshot, and deletion protection."
  type        = bool
  default     = false
}

# ---- Per-app databases + roles (optional, needs network reach to RDS) ----
variable "manage_databases" {
  type    = bool
  default = false
}
variable "app1_db_name" {
  type    = string
  default = "serviot_app1"
}
variable "app1_db_user" {
  type    = string
  default = "app1"
}
variable "app1_db_password" {
  type      = string
  sensitive = true
  default   = ""
}
variable "app2_db_name" {
  type    = string
  default = "serviot_app2"
}
variable "app2_db_user" {
  type    = string
  default = "app2"
}
variable "app2_db_password" {
  type      = string
  sensitive = true
  default   = ""
}
