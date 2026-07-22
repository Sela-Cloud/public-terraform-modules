output "subnetworks" {
  description = "Created subnetwork self links by configuration key."
  value       = { for key, subnet in google_compute_subnetwork.this : key => subnet.self_link }
}

output "gateway_addresses" {
  description = "Created subnet gateway addresses by configuration key."
  value       = { for key, subnet in google_compute_subnetwork.this : key => subnet.gateway_address }
}
