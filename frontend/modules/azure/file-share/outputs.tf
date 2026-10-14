output "file_shares" {
  description = "Map of created File Shares and their attributes."
  value       = module.file_share
}

output "file_share_ids" {
  description = "Map of File Share names to their resource IDs."
  value       = { for k, v in module.file_share : k => v.id }
}

output "file_share_urls" {
  description = "Map of File Share names to their URLs."
  value       = { for k, v in module.file_share : k => v.url }
}
