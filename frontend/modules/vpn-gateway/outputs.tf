output "gateway_ip_addresses" {
  value = { for key, gw in module.vpn_gateway : key => gw.ip_address }
}

output "gateway_self_links" {
  value = { for key, gw in module.vpn_gateway : key => gw.gateway_self_link }
}
