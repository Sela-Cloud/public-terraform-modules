output "id" {
  description = "The ID of the Container App."
  value       = azurerm_container_app.container_app.id
}

output "name" {
  description = "The Name of the Container App."
  value       = azurerm_container_app.container_app.name
}

output "fqdn" {
  description = "The FQDN of the Container App's ingress, if ingress is enabled."
  value       = try(azurerm_container_app.container_app.ingress[0].fqdn, null)
}

output "latest_revision_fqdn" {
  description = "The FQDN of the Latest Revision of the Container App."
  value       = azurerm_container_app.container_app.latest_revision_fqdn
}

output "latest_revision_name" {
  description = "The name of the latest Container Revision."
  value       = azurerm_container_app.container_app.latest_revision_name
}

output "outbound_ip_addresses" {
  description = "The list of the Public IP Addresses used by the Container App for outbound network access."
  value       = azurerm_container_app.container_app.outbound_ip_addresses
}

output "identity" {
  description = "The Managed Identity configuration block for the Container App."
  value       = azurerm_container_app.container_app.identity
}

output "container_app" {
  description = "The full Azure Container App resource object."
  value       = azurerm_container_app.container_app
}
