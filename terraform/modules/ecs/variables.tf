variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "alb_target_group_arn" {
  description = "ARN of the Next.js ALB target group"
  type        = string
}

variable "hasura_target_group_arn" {
  description = "ARN of the Hasura ALB target group"
  type        = string
}

variable "database_url" {
  description = "PostgreSQL database URL"
  type        = string
  sensitive   = true
}

variable "hasura_admin_secret" {
  description = "Hasura admin secret"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret"
  type        = string
  sensitive   = true
}

variable "hasura_image" {
  description = "Hasura Docker image"
  type        = string
}

variable "hasura_cpu" {
  description = "CPU units for Hasura container"
  type        = number
}

variable "hasura_memory" {
  description = "Memory for Hasura container in MB"
  type        = number
}

variable "hasura_desired_count" {
  description = "Desired number of Hasura tasks"
  type        = number
}

variable "nextjs_image" {
  description = "Next.js Docker image"
  type        = string
}

variable "nextjs_cpu" {
  description = "CPU units for Next.js container"
  type        = number
}

variable "nextjs_memory" {
  description = "Memory for Next.js container in MB"
  type        = number
}

variable "nextjs_desired_count" {
  description = "Desired number of Next.js tasks"
  type        = number
}

variable "nextauth_secret" {
  description = "NextAuth secret"
  type        = string
  sensitive   = true
}

variable "nextauth_url" {
  description = "NextAuth URL"
  type        = string
}
