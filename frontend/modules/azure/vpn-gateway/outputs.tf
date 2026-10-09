output "vpn_gateways" {
  description = "A map of all created Azure VPN Gateway module instances."
  value       = module.vpn_gateway
}

output "vpn_gateway_ids" {
  description = "A map of VPN Gateway names to their respective resource IDs."
  value       = { for k, v in module.vpn_gateway : k => v.id }
}
