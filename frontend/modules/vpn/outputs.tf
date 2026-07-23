output "vpn_gateway_addresses" {
  value = { for key, instance in module.vpn : key => instance.gateway_address }
}

output "vpn_tunnels" {
  value     = { for key, instance in module.vpn : key => instance.tunnel_self_link }
  sensitive = true
}
