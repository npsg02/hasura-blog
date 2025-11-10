output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "hasura_service_name" {
  description = "Name of the Hasura ECS service"
  value       = aws_ecs_service.hasura.name
}

output "nextjs_service_name" {
  description = "Name of the Next.js ECS service"
  value       = aws_ecs_service.nextjs.name
}

output "hasura_task_definition_arn" {
  description = "ARN of the Hasura task definition"
  value       = aws_ecs_task_definition.hasura.arn
}

output "nextjs_task_definition_arn" {
  description = "ARN of the Next.js task definition"
  value       = aws_ecs_task_definition.nextjs.arn
}
