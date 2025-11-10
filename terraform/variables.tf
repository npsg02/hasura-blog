variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "hasura-blog"
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Database
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "hasura"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# Hasura
variable "hasura_admin_secret" {
  description = "Hasura admin secret"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret for Hasura (min 32 characters)"
  type        = string
  sensitive   = true
}

variable "hasura_image" {
  description = "Hasura Docker image"
  type        = string
  default     = "hasura/graphql-engine:v2.43.0"
}

variable "hasura_cpu" {
  description = "CPU units for Hasura container (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "hasura_memory" {
  description = "Memory for Hasura container in MB"
  type        = number
  default     = 1024
}

variable "hasura_desired_count" {
  description = "Desired number of Hasura tasks"
  type        = number
  default     = 2
}

# Next.js
variable "nextjs_image" {
  description = "Next.js Docker image (should be pushed to ECR)"
  type        = string
}

variable "nextjs_cpu" {
  description = "CPU units for Next.js container (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "nextjs_memory" {
  description = "Memory for Next.js container in MB"
  type        = number
  default     = 1024
}

variable "nextjs_desired_count" {
  description = "Desired number of Next.js tasks"
  type        = number
  default     = 2
}

variable "nextauth_secret" {
  description = "NextAuth secret"
  type        = string
  sensitive   = true
}

variable "nextauth_url" {
  description = "NextAuth URL (your application URL)"
  type        = string
}
