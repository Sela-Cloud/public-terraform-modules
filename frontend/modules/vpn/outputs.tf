output "vpn_gateway_addresses" {
  value = module.vpn.vpn_gateway_addresses
}

output "vpn_tunnels" {
  value     = module.vpn.vpn_tunnels
  sensitive = true
}
