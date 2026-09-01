output "id" {
  description = "Full resource name of the certificate."
  value       = google_certificate_manager_certificate.this.id
}

output "state" {
  description = "Provisioning state of the managed certificate (e.g. ACTIVE, PROVISIONING, FAILED)."
  value       = google_certificate_manager_certificate.this.managed[0].state
}
