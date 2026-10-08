output "id" {
  description = "The ID of the Front Door."
  value       = azurerm_frontdoor.frontdoor.id
}

output "name" {
  description = "The Name of the Front Door."
  value       = azurerm_frontdoor.frontdoor.name
}

output "cname" {
  description = "The host that each frontendEndpoint must CNAME to."
  value       = azurerm_frontdoor.frontdoor.cname
}

output "header_frontdoor_id" {
  description = "The unique ID of the Front Door which is sent as the X-Azure-FDID header, once the domain is resolved."
  value       = azurerm_frontdoor.frontdoor.header_frontdoor_id
}

output "frontend_endpoints" {
  description = "The frontend endpoints mapping of the Front Door."
  value       = azurerm_frontdoor.frontdoor.frontend_endpoints
}

output "frontdoor" {
  description = "The full Azure Front Door resource object."
  value       = azurerm_frontdoor.frontdoor
}
