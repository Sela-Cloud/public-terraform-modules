output "id" {
  description = "Full resource name of the policy."
  value       = google_network_connectivity_service_connection_policy.this.id
}

output "psc_connections" {
  description = "PSC connections created under this policy."
  value       = google_network_connectivity_service_connection_policy.this.psc_connections
}
