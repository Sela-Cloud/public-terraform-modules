output "certificate_ids" {
  description = "Full resource name of each certificate, keyed by resource name."
  value       = { for key, cert in module.global_certificate_google_managed : key => cert.id }
}

output "certificate_states" {
  description = "Provisioning state of each certificate, keyed by resource name."
  value       = { for key, cert in module.global_certificate_google_managed : key => cert.state }
}
