output "storage_blobs" {
  description = "Map of created Storage Blobs and their attributes."
  value       = module.storage_blob
}

output "storage_blob_ids" {
  description = "Map of Storage Blob names to their Azure resource IDs."
  value       = { for k, v in module.storage_blob : k => v.id }
}

output "storage_blob_urls" {
  description = "Map of Storage Blob names to their allocated blob URLs."
  value       = { for k, v in module.storage_blob : k => v.url }
}
