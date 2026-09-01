output "id" {
  description = "Full resource name of the certificate."
  value       = google_certificate_manager_certificate.this.id
}

output "san_dnsnames" {
  description = "SAN DNS names parsed from the uploaded certificate."
  value       = google_certificate_manager_certificate.this.san_dnsnames
}
