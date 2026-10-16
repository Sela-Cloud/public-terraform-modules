output "function_apps" {
  description = "Map of created Function Apps and their attributes."
  value       = module.function_app
  sensitive   = true
}

output "function_app_ids" {
  description = "Map of Function App names to their Azure resource IDs."
  value       = { for k, v in module.function_app : k => v.id }
}

output "function_app_hostnames" {
  description = "Map of Function App names to their default hostnames."
  value       = { for k, v in module.function_app : k => v.default_hostname }
}
