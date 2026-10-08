output "nat_gateways" {
  description = "Map of created NAT Gateways and their attributes."
  value       = module.nat_gateway
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway names to their Azure resource IDs."
  value       = { for k, v in module.nat_gateway : k => v.id }
}
