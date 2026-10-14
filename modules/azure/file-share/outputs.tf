output "id" {
  description = "The ID of the File Share."
  value       = azurerm_storage_share.share.id
}

output "name" {
  description = "The name of the File Share."
  value       = azurerm_storage_share.share.name
}

output "quota" {
  description = "The quota of the File Share in GB."
  value       = azurerm_storage_share.share.quota
}

output "url" {
  description = "The URL of the File Share."
  value       = azurerm_storage_share.share.url
}

output "file_share" {
  description = "The full Azure Storage File Share resource object."
  value       = azurerm_storage_share.share
}
