output "vpn_gateways" {
  description = "A map of all created Azure VPN Gateway module instances."
  value       = module.vpn_gateway
}

output "vpn_gateway_ids" {
  description = "A map of VPN Gateway names to their respective resource IDs."
  value       = { for k, v in module.vpn_gateway : k => v.id }
}

output "virtual_hub_ids" {
  description = "A map of VPN Gateway names to the Virtual Hub created for each."
  value       = { for k, v in module.vpn_gateway : k => v.virtual_hub_id }
}

output "virtual_wan_ids" {
  description = "A map of VPN Gateway names to the Virtual WAN created for each."
  value       = { for k, v in module.vpn_gateway : k => v.virtual_wan_id }
}
