output "address" {
  description = "The reserved IP address value."
  value       = google_compute_address.this.address
}

output "self_link" {
  description = "Self link of the reserved address."
  value       = google_compute_address.this.self_link
}
