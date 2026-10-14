output "arn" {
  description = "ARN of the task definition revision, family:revision included. Pass it to an ECS service."
  value       = aws_ecs_task_definition.this.arn
}

output "family" {
  description = "Task definition family."
  value       = aws_ecs_task_definition.this.family
}

output "revision" {
  description = "Revision number registered by the latest apply."
  value       = aws_ecs_task_definition.this.revision
}

output "log_group_name" {
  description = "CloudWatch log group the containers write to, or null when no container logs."
  value       = local.logging ? aws_cloudwatch_log_group.this[0].name : null
}
