output "service_account_emails" {
  description = "A list of service accounts receiving project-level IAM roles."
  value = [
    for key, service_account in module.service_accounts :
    service_account.email
    if contains(keys(local.project_role_configs), key)
  ]
}

output "user_email_addresses" {
  description = "A list of users receiving project-level IAM roles."
  value = [
    for config in local.project_role_configs :
    config.user_email_address
    if config.user_email_address != null
  ]
}

output "custom_roles" {
  description = "A list of the created Custom role IDs"
  value       = [for role in module.custom_roles : role.custom_role_id]
}
