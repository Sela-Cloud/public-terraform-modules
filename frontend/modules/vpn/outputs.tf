output "vpn_gateway_addresses" {
  value = { for key, address in google_compute_address.this : key => address.address }
}

output "vpn_tunnels" {
  value     = { for key, tunnel in google_compute_vpn_tunnel.this : key => tunnel.self_link }
  sensitive = true
}
