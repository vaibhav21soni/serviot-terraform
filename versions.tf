terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    # Used to create the per-app databases + scoped roles inside the one RDS
    # instance. Optional — gated behind var.manage_databases (see databases.tf).
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  # Remote state is recommended so credentials in state are not on a laptop.
  # Fill in and uncomment for a real deployment.
  # backend "s3" {
  #   bucket         = "serviot-tfstate"
  #   key            = "serviot/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "serviot-tflock"
  #   encrypt        = true
  # }
}
