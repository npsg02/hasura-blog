output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "nextjs_url" {
  description = "URL for Next.js application"
  value       = "http://${module.alb.alb_dns_name}"
}

output "hasura_graphql_url" {
  description = "URL for Hasura GraphQL API"
  value       = "http://${module.alb.alb_dns_name}/v1/graphql"
}

output "hasura_console_url" {
  description = "URL for Hasura Console"
  value       = "http://${module.alb.alb_dns_name}:8080/console"
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_hasura_service_name" {
  description = "Name of the Hasura ECS service"
  value       = module.ecs.hasura_service_name
}

output "ecs_nextjs_service_name" {
  description = "Name of the Next.js ECS service"
  value       = module.ecs.nextjs_service_name
}
