output "gateway_address" {
  value = google_compute_address.this.address
}

output "tunnel_self_link" {
  value     = google_compute_vpn_tunnel.this.self_link
  sensitive = true
}
