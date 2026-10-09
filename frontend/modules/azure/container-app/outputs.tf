output "container_apps" {
  description = "A map of all created Azure Container App module instances."
  value       = module.container_app
}

output "container_app_ids" {
  description = "A map of Container App names to their respective resource IDs."
  value       = { for k, v in module.container_app : k => v.id }
}

output "container_app_fqdns" {
  description = "A map of Container App names to their respective FQDNs."
  value       = { for k, v in module.container_app : k => v.fqdn }
}
