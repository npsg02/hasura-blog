terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment to use S3 backend for state storage
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "hasura-blog/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "hasura-blog"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project_name           = var.project_name
  environment            = var.environment
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  db_instance_class      = var.db_instance_class
  allocated_storage      = var.allocated_storage
  subnet_ids             = module.vpc.private_subnet_ids
  security_group_ids     = [module.security.rds_security_group_id]
  backup_retention_period = var.backup_retention_period
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [module.security.alb_security_group_id]
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  alb_target_group_arn    = module.alb.nextjs_target_group_arn
  hasura_target_group_arn = module.alb.hasura_target_group_arn
  security_group_ids      = [module.security.ecs_security_group_id]
  
  # Database configuration
  database_url = "postgres://${var.db_username}:${var.db_password}@${module.rds.db_endpoint}/${var.db_name}"
  
  # Hasura configuration
  hasura_admin_secret   = var.hasura_admin_secret
  jwt_secret            = var.jwt_secret
  hasura_image          = var.hasura_image
  hasura_cpu            = var.hasura_cpu
  hasura_memory         = var.hasura_memory
  hasura_desired_count  = var.hasura_desired_count
  
  # Next.js configuration
  nextjs_image         = var.nextjs_image
  nextjs_cpu           = var.nextjs_cpu
  nextjs_memory        = var.nextjs_memory
  nextjs_desired_count = var.nextjs_desired_count
  nextauth_secret      = var.nextauth_secret
  nextauth_url         = var.nextauth_url
}
