output "manage_identities" {
  description = "Map of created Managed Identities and their attributes."
  value       = module.manage_identities
}

output "manage_identity_ids" {
  description = "Map of Managed Identity names to their Azure resource IDs."
  value       = { for k, v in module.manage_identities : k => v.id }
}

output "manage_identity_principal_ids" {
  description = "Map of Managed Identity names to their principal IDs (object IDs)."
  value       = { for k, v in module.manage_identities : k => v.principal_id }
}

output "manage_identity_client_ids" {
  description = "Map of Managed Identity names to their client IDs (application IDs)."
  value       = { for k, v in module.manage_identities : k => v.client_id }
}
