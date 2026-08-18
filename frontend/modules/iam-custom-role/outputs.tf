output "custom_roles" {
  description = "Created custom role IDs keyed by the configured resource key."
  value       = { for key, role in module.iam_custom_role : key => role.custom_role_id }
}
