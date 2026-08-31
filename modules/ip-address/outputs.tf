output "address" {
  description = "The reserved IP address value."
  value       = var.type == "REGIONAL" ? google_compute_address.regional[0].address : google_compute_global_address.global[0].address
}

output "self_link" {
  description = "Self link of the reserved address."
  value       = var.type == "REGIONAL" ? google_compute_address.regional[0].self_link : google_compute_global_address.global[0].self_link
}
