output "local_network_gateways" {
  description = "A map of all created Azure Local Network Gateway module instances."
  value       = module.local_network_gateway
}

output "local_network_gateway_ids" {
  description = "A map of Local Network Gateway names to their respective resource IDs."
  value       = { for k, v in module.local_network_gateway : k => v.id }
}
