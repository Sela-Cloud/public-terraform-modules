output "app_services" {
  description = "Map of created App Services and their attributes."
  value       = module.app_service
}

output "app_service_ids" {
  description = "Map of App Service names to their Azure resource IDs."
  value       = { for k, v in module.app_service : k => v.id }
}

output "app_service_hostnames" {
  description = "Map of App Service names to their default hostnames."
  value       = { for k, v in module.app_service : k => v.default_hostname }
}
