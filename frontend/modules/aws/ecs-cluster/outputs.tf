output "cluster_arns" {
  description = "ARN of each cluster, keyed by name."
  value       = { for k, c in module.ecs_cluster : k => c.arn }
}

output "capacity_providers" {
  description = "Capacity providers registered with each cluster, keyed by name."
  value       = { for k, c in module.ecs_cluster : k => c.capacity_providers }
}
