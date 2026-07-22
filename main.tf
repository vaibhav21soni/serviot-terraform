# Root: wires the self-authored modules. Two EC2 instances (app + jenkins) are
# driven by var.instances + for_each inside the compute module.

locals {
  common_tags = {
    Project   = var.project
    ManagedBy = "terraform"
  }

  # SG definitions consumed by the security module's dynamic ingress block.
  # Keys == instance roles so compute can look SGs up by role.
  security_groups = {
    app = {
      description = "App server: web public, SSH admin-only"
      ingress = [
        { description = "HTTPS public", from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { description = "HTTP public", from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { description = "SSH admin-only", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = [var.admin_ip_cidr] },
        { description = "SSH from VPC (Jenkins deploy)", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = [var.vpc_cidr] },
      ]
    }
    jenkins = {
      description = "Jenkins server: CI port + SSH admin-only"
      ingress = [
        { description = "Jenkins UI", from_port = var.jenkins_port, to_port = var.jenkins_port, protocol = "tcp", cidr_blocks = var.jenkins_ingress_cidrs },
        { description = "SSH admin-only", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = [var.admin_ip_cidr] },
      ]
    }
  }
}

module "network" {
  source   = "./modules/network"
  project  = var.project
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
  tags     = local.common_tags
}

module "security" {
  source          = "./modules/security"
  project         = var.project
  vpc_id          = module.network.vpc_id
  security_groups = local.security_groups
  tags            = local.common_tags
}

module "compute" {
  source             = "./modules/compute"
  project            = var.project
  instances          = var.instances
  subnet_id          = module.network.public_subnet_ids[0]
  create_key_pair    = var.create_key_pair
  existing_key_name  = var.existing_key_name
  security_group_ids = module.security.security_group_ids
  jenkins_port       = var.jenkins_port
  tags               = local.common_tags
}

module "database" {
  source                     = "./modules/database"
  project                    = var.project
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.private_subnet_ids
  allowed_security_group_ids = [module.security.security_group_ids["app"]]
  instance_class             = var.db_instance_class
  allocated_storage          = var.db_allocated_storage
  engine_version             = var.db_engine_version
  db_name                    = var.app1_db_name
  username                   = var.master_username
  password                   = var.master_password
  enable_backups             = var.enable_backups
  tags                       = local.common_tags
}

module "iam" {
  source  = "./modules/iam"
  project = var.project
  tags    = local.common_tags
}
