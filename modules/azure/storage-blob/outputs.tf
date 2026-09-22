output "id" {
  description = "The ID of the Storage Blob."
  value       = azurerm_storage_blob.storage_blob.id
}

output "url" {
  description = "The URL of the Storage Blob."
  value       = azurerm_storage_blob.storage_blob.url
}

output "name" {
  description = "The name of the Storage Blob."
  value       = azurerm_storage_blob.storage_blob.name
}

output "storage_container_id" {
  description = "The ID of the Storage Container in which the blob was created."
  value       = azurerm_storage_blob.storage_blob.storage_container_id
}

output "type" {
  description = "The type of the Storage Blob."
  value       = azurerm_storage_blob.storage_blob.type
}

output "access_tier" {
  description = "The access tier of the Storage Blob."
  value       = azurerm_storage_blob.storage_blob.access_tier
}

output "content_type" {
  description = "The content type of the Storage Blob."
  value       = azurerm_storage_blob.storage_blob.content_type
}

output "metadata" {
  description = "The metadata assigned to the Storage Blob."
  value       = azurerm_storage_blob.storage_blob.metadata
}

output "storage_blob" {
  description = "The full Azure Storage Blob resource object."
  value       = azurerm_storage_blob.storage_blob
}
