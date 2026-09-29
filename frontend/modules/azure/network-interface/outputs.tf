output "network_interfaces" {
  description = "Map of created Network Interfaces and their attributes."
  value       = module.network_interface
}

output "network_interface_ids" {
  description = "Map of Network Interface names to their Azure resource IDs."
  value       = { for k, v in module.network_interface : k => v.id }
}
