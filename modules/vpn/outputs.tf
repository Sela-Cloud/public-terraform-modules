output "gateway_address" {
  value = google_compute_address.this.address
}

output "tunnel_self_link" {
  value     = google_compute_vpn_tunnel.this.self_link
  sensitive = true
}

output "route_self_links" {
  description = "Self link of each route created for a ROUTE_BASED tunnel, keyed by destination CIDR."
  value       = { for k, v in google_compute_route.this : k => v.self_link }
}
