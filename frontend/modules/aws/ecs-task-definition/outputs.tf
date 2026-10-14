output "task_definition_arns" {
  description = "ARN (family:revision) of each task definition, keyed by family."
  value       = { for k, td in module.ecs_task_definition : k => td.arn }
}

output "log_group_names" {
  description = "CloudWatch log group of each task definition, keyed by family."
  value       = { for k, td in module.ecs_task_definition : k => td.log_group_name }
}
