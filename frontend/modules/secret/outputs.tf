output "secret_ids" {
  description = "Full resource name of each secret, keyed by resource name."
  value       = { for key, s in module.secret : key => s.id }
}
