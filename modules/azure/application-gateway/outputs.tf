output "id" {
  description = "The ID of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.id
}

output "name" {
  description = "The Name of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.name
}

output "resource_group_name" {
  description = "The Resource Group Name of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.resource_group_name
}

output "location" {
  description = "The Azure Region of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.location
}

output "frontend_ip_configuration" {
  description = "The frontend IP configurations of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.frontend_ip_configuration
}

output "frontend_port" {
  description = "The frontend ports of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.frontend_port
}

output "gateway_ip_configuration" {
  description = "The gateway IP configurations of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.gateway_ip_configuration
}

output "backend_address_pool" {
  description = "The backend address pools of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.backend_address_pool
}

output "backend_http_settings" {
  description = "The backend HTTP settings of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.backend_http_settings
}

output "http_listener" {
  description = "The HTTP listeners of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.http_listener
}

output "request_routing_rule" {
  description = "The request routing rules of the Application Gateway."
  value       = azurerm_application_gateway.app_gateway.request_routing_rule
}

output "application_gateway" {
  description = "The full Azure Application Gateway resource object."
  value       = azurerm_application_gateway.app_gateway
}
