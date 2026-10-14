output "id" {
  description = "The ID of the Container App Environment."
  value       = azurerm_container_app_environment.environment.id
}

output "name" {
  description = "The name of the Container App Environment."
  value       = azurerm_container_app_environment.environment.name
}

output "resource_group_name" {
  description = "The name of the Resource Group where the Container App Environment exists."
  value       = azurerm_container_app_environment.environment.resource_group_name
}

output "location" {
  description = "The Azure Region where the Container App Environment exists."
  value       = azurerm_container_app_environment.environment.location
}

output "default_domain" {
  description = "The default publicly resolvable domain name suffix for applications hosted in this environment."
  value       = azurerm_container_app_environment.environment.default_domain
}

output "static_ip_address" {
  description = "The static IP address assigned to the Container App Environment."
  value       = azurerm_container_app_environment.environment.static_ip_address
}

output "custom_domain_verification_id" {
  description = "The unique verification code used for configuring DNS TXT records for custom domain ownership verification."
  value       = azurerm_container_app_environment.environment.custom_domain_verification_id
}

output "docker_bridge_cidr" {
  description = "The network CIDR used by the internal Docker bridge network."
  value       = azurerm_container_app_environment.environment.docker_bridge_cidr
}

output "platform_reserved_cidr" {
  description = "The network CIDR reserved for platform infrastructure services."
  value       = azurerm_container_app_environment.environment.platform_reserved_cidr
}

output "platform_reserved_dns_ip_address" {
  description = "The IP address reserved for internal DNS resolution within the platform network."
  value       = azurerm_container_app_environment.environment.platform_reserved_dns_ip_address
}

output "identity" {
  description = "The Managed Service Identity configuration block associated with this environment."
  value       = azurerm_container_app_environment.environment.identity
}

output "container_app_environment" {
  description = "The full Azure Container App Environment resource object."
  value       = azurerm_container_app_environment.environment
}
