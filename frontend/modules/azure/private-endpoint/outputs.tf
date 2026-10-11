output "private_endpoints" {
  description = "Map of created Private Endpoints and their attributes."
  value       = module.private_endpoint
}

output "private_endpoint_ids" {
  description = "Map of Private Endpoint names to their Azure resource IDs."
  value       = { for k, v in module.private_endpoint : k => v.id }
}

output "network_interfaces" {
  description = "Map of Private Endpoint names to their underlying network interface objects."
  value       = { for k, v in module.private_endpoint : k => v.network_interface }
}
