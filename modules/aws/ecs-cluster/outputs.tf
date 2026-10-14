output "arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.this.arn
}

output "name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "capacity_providers" {
  description = "Capacity providers registered with the cluster."
  value       = local.capacity_providers
}
