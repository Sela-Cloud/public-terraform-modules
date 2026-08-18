output "iam_users" {
  description = "Cloud SQL IAM database user names keyed by the configured resource key."
  value       = { for key, user in module.cloud_sql_user : key => user.name }
}
