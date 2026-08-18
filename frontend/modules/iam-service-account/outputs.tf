output "service_account_emails" {
  description = "Created service account emails keyed by the configured resource key."
  value       = { for key, service_account in module.iam_service_account : key => service_account.email }
}
