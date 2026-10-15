output "id" {
  description = "The ID of the Storage Container."
  value       = azurerm_storage_container.container.id
}

output "name" {
  description = "The name of the Storage Container."
  value       = azurerm_storage_container.container.name
}

output "container_access_type" {
  description = "The Access Level configured for this Container."
  value       = azurerm_storage_container.container.container_access_type
}

output "container" {
  description = "The full Azure Storage Container resource object."
  value       = azurerm_storage_container.container
}

output "blobs" {
  description = "Map of created storage blob resource objects."
  value       = azurerm_storage_blob.blobs
}
