output "version_ids" {
  description = "Full resource name of each secret version, keyed by resource name."
  value       = { for key, v in module.secret_version : key => v.id }
}
