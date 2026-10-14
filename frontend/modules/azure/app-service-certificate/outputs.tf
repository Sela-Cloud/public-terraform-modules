output "app_service_certificates" {
  description = "Map of created App Service Certificates and their attributes."
  value       = module.app_service_certificate
  sensitive   = true
}

output "app_service_certificate_ids" {
  description = "Map of certificate keys to their Azure resource IDs."
  value       = { for k, v in module.app_service_certificate : k => v.id }
}

output "app_service_certificate_names" {
  description = "Map of certificate keys to their names."
  value       = { for k, v in module.app_service_certificate : k => v.name }
}

output "app_service_certificate_thumbprints" {
  description = "Map of certificate keys to their certificate thumbprints."
  value       = { for k, v in module.app_service_certificate : k => v.thumbprint }
}

output "app_service_certificate_host_names" {
  description = "Map of certificate keys to their host names."
  value       = { for k, v in module.app_service_certificate : k => v.host_names }
}
