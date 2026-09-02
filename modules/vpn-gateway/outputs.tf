output "gateway_self_link" {
  description = "Self link of the target VPN gateway, for a vpn-tunnel to attach to."
  value       = google_compute_vpn_gateway.this.self_link
}

output "gateway_name" {
  description = "Name of the target VPN gateway resource."
  value       = google_compute_vpn_gateway.this.name
}

output "ip_address" {
  description = "The gateway's external IP address, whether newly reserved or reused."
  value       = local.gateway_ip_address
}
