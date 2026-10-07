output "id" {
  description = "The ID of the App Service (Web App)."
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.linux_app[0].id : azurerm_windows_web_app.windows_app[0].id
}

output "name" {
  description = "The name of the App Service."
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.linux_app[0].name : azurerm_windows_web_app.windows_app[0].name
}

output "default_hostname" {
  description = "The default hostname associated with the App Service (e.g. myapp.azurewebsites.net)."
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.linux_app[0].default_hostname : azurerm_windows_web_app.windows_app[0].default_hostname
}

output "service_plan_id" {
  description = "The ID of the App Service Plan associated with this App Service."
  value       = local.service_plan_id
}

output "outbound_ip_addresses" {
  description = "A comma-separated list of outbound IP addresses used by the App Service."
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.linux_app[0].outbound_ip_addresses : azurerm_windows_web_app.windows_app[0].outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "A comma-separated list of all possible outbound IP addresses for the App Service."
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.linux_app[0].possible_outbound_ip_addresses : azurerm_windows_web_app.windows_app[0].possible_outbound_ip_addresses
}

output "identity_principal_id" {
  description = "The Principal ID of the System-Assigned Managed Identity, if enabled."
  value = var.os_type == "Linux" ? (
    length(azurerm_linux_web_app.linux_app[0].identity) > 0 ? azurerm_linux_web_app.linux_app[0].identity[0].principal_id : null
    ) : (
    length(azurerm_windows_web_app.windows_app[0].identity) > 0 ? azurerm_windows_web_app.windows_app[0].identity[0].principal_id : null
  )
}

output "identity_tenant_id" {
  description = "The Tenant ID of the System-Assigned Managed Identity, if enabled."
  value = var.os_type == "Linux" ? (
    length(azurerm_linux_web_app.linux_app[0].identity) > 0 ? azurerm_linux_web_app.linux_app[0].identity[0].tenant_id : null
    ) : (
    length(azurerm_windows_web_app.windows_app[0].identity) > 0 ? azurerm_windows_web_app.windows_app[0].identity[0].tenant_id : null
  )
}

output "web_app" {
  description = "The full Azure Web App resource object."
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.linux_app[0] : azurerm_windows_web_app.windows_app[0]
  sensitive   = true
}
