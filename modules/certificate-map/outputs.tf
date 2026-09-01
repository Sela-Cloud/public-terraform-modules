output "id" {
  description = "Full resource name of the certificate map."
  value       = google_certificate_manager_certificate_map.this.id
}

output "gclb_targets" {
  description = "Load balancer target proxies that use this certificate map."
  value       = google_certificate_manager_certificate_map.this.gclb_targets
}

output "entry_states" {
  description = "Serving state of each entry, keyed by entry name."
  value       = { for key, entry in google_certificate_manager_certificate_map_entry.entries : key => entry.state }
}
