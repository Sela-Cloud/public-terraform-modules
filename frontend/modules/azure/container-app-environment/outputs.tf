output "container_app_environments" {
  description = "Map of created Container App Environments and their attributes."
  value       = module.container_app_environment
}

output "container_app_environment_ids" {
  description = "Map of Container App Environment names to their resource IDs."
  value       = { for k, v in module.container_app_environment : k => v.id }
}

output "default_domains" {
  description = "Map of Container App Environment names to their default domain name suffixes."
  value       = { for k, v in module.container_app_environment : k => v.default_domain }
}
