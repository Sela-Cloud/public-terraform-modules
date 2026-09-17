output "certificate_ids" {
  description = "Full resource name of each certificate, keyed by resource name."
  value       = { for key, cert in module.global_certificate_self_managed : key => cert.id }
}
