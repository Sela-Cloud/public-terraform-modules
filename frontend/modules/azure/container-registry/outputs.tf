output "container_registries" {
  description = "Map of created Container Registries and their attributes."
  value       = module.container_registry
  sensitive   = true
}

output "container_registry_ids" {
  description = "Map of Container Registry names to their Azure resource IDs."
  value       = { for k, v in module.container_registry : k => v.id }
}

output "container_registry_login_servers" {
  description = "Map of Container Registry names to their login servers."
  value       = { for k, v in module.container_registry : k => v.login_server }
}

output "container_registry_admin_usernames" {
  description = "Map of Container Registry names to their admin usernames (if admin is enabled)."
  value       = { for k, v in module.container_registry : k => v.admin_username }
}
