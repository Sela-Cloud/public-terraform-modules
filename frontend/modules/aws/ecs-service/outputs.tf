output "service_ids" {
  description = "ARN of each service, keyed by name."
  value       = { for k, s in module.ecs_service : k => s.id }
}
