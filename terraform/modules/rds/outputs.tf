output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_arn" {
  description = "RDS ARN"
  value       = aws_db_instance.main.arn
}

output "db_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}
