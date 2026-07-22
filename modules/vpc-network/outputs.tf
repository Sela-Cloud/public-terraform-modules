output "networks" {
  description = "Created VPC network self links by configuration key."
  value       = { for key, network in google_compute_network.this : key => network.self_link }
}

output "network_ids" {
  description = "Created VPC network IDs by configuration key."
  value       = { for key, network in google_compute_network.this : key => network.id }
}
