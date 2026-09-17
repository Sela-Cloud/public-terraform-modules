output "reserved_range_name" { value = google_compute_global_address.this.name }
output "connection" { value = google_service_networking_connection.this.peering }
output "network" { value = data.google_compute_network.this.self_link }
