output "storage_accounts" {
  description = "Map of created Storage Accounts and their attributes."
  value       = module.storage_account
  sensitive   = true
}

output "storage_account_ids" {
  description = "Map of Storage Account names to their Azure resource IDs."
  value       = { for k, v in module.storage_account : k => v.id }
}

output "primary_blob_endpoints" {
  description = "Map of Storage Account names to their primary blob endpoint URLs."
  value       = { for k, v in module.storage_account : k => v.primary_blob_endpoint }
}
