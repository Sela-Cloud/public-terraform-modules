output "id" {
  description = "Full resource name of the DNS authorization, as referenced by a managed certificate."
  value       = google_certificate_manager_dns_authorization.this.id
}

output "dns_resource_record" {
  description = "The DNS record to create in the domain's DNS zone to complete validation."
  value       = google_certificate_manager_dns_authorization.this.dns_resource_record
}
