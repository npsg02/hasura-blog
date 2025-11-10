output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "nextjs_target_group_arn" {
  description = "ARN of Next.js target group"
  value       = aws_lb_target_group.nextjs.arn
}

output "hasura_target_group_arn" {
  description = "ARN of Hasura target group"
  value       = aws_lb_target_group.hasura.arn
}
