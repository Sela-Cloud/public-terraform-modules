output "id" {
  description = "The ID of the Container Registry."
  value       = azurerm_container_registry.container_registry.id
}

output "name" {
  description = "The Name of the Container Registry."
  value       = azurerm_container_registry.container_registry.name
}

output "login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = azurerm_container_registry.container_registry.login_server
}

output "admin_username" {
  description = "The Username associated with the Container Registry Admin account."
  value       = azurerm_container_registry.container_registry.admin_username
}

output "admin_password" {
  description = "The Password associated with the Container Registry Admin account."
  value       = azurerm_container_registry.container_registry.admin_password
  sensitive   = true
}

output "resource_group_name" {
  description = "The Name of the Resource Group in which the Container Registry was created."
  value       = azurerm_container_registry.container_registry.resource_group_name
}

output "location" {
  description = "The Azure Region of the Container Registry."
  value       = azurerm_container_registry.container_registry.location
}

output "sku" {
  description = "The SKU of the Container Registry."
  value       = azurerm_container_registry.container_registry.sku
}

output "admin_enabled" {
  description = "Whether the admin user is enabled for the Container Registry."
  value       = azurerm_container_registry.container_registry.admin_enabled
}

output "tags" {
  description = "The tags assigned to the Container Registry."
  value       = azurerm_container_registry.container_registry.tags
}

output "container_registry" {
  description = "The full Azure Container Registry resource object."
  value       = azurerm_container_registry.container_registry
  sensitive   = true
}
