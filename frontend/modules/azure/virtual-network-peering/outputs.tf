output "virtual_network_peerings" {
  description = "Map of created Virtual Network Peerings and their attributes."
  value       = module.virtual_network_peering
}

output "virtual_network_peering_ids" {
  description = "Map of Virtual Network Peering names to their Azure resource IDs."
  value       = { for k, v in module.virtual_network_peering : k => v.id }
}
