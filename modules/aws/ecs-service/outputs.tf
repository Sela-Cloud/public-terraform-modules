output "id" {
  description = "ARN of the ECS service."
  value       = aws_ecs_service.this.id
}

output "name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "autoscaling_policy_arns" {
  description = "ARNs of the target tracking policies, keyed by policy name."
  value       = { for k, p in aws_appautoscaling_policy.this : k => p.arn }
}
