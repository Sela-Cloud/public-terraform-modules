output "virtual_networks" {
  description = "Map of created Virtual Networks and their attributes."
  value       = module.virtual_network
}

output "virtual_network_ids" {
  description = "Map of Virtual Network names to their Azure resource IDs."
  value       = { for k, v in module.virtual_network : k => v.id }
}

output "virtual_network_address_spaces" {
  description = "Map of Virtual Network names to their configured address spaces."
  value       = { for k, v in module.virtual_network : k => v.address_space }
}
