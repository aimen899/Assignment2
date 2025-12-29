# Terraform Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_cidr_block    = var.vpc_cidr_block
  subnet_cidr_block = var. subnet_cidr_block
  availability_zone = var.availability_zone
  env_prefix        = var.env_prefix
}

# Security Module
module "security" {
  source = "./modules/security"

  vpc_id     = module.networking. vpc_id
  env_prefix = var.env_prefix
  my_ip      = local.my_ip
}

# Nginx Server
module "nginx_server" {
  source = "./modules/webserver"

  env_prefix        = var.env_prefix
  instance_name     = "nginx-proxy"
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking. subnet_id
  security_group_id = module.security. nginx_sg_id
  public_key        = var.public_key
  script_path       = "./scripts/nginx-setup.sh"
  instance_suffix   = "nginx"
  common_tags       = local.common_tags
}

# Backend Servers (using for_each)
module "backend_servers" {
  for_each = { for idx, server in local. backend_servers : server.name => server }

  source = "./modules/webserver"

  env_prefix        = var.env_prefix
  instance_name     = each.value.name
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  vpc_id            = module.networking.vpc_id
  subnet_id         = module. networking.subnet_id
  security_group_id = module. security.backend_sg_id
  public_key        = var.public_key
  script_path       = each.value.script_path
  instance_suffix   = each. value.suffix
  common_tags       = local.common_tags
}
