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

output "containers" {
  description = "Map of Storage Account names to their created containers."
  value       = { for k, v in module.storage_account : k => v.containers }
}

output "file_shares" {
  description = "Map of Storage Account names to their created file shares."
  value       = { for k, v in module.storage_account : k => v.file_shares }
}

output "tables" {
  description = "Map of Storage Account names to their created tables."
  value       = { for k, v in module.storage_account : k => v.tables }
}

output "queues" {
  description = "Map of Storage Account names to their created queues."
  value       = { for k, v in module.storage_account : k => v.queues }
}
