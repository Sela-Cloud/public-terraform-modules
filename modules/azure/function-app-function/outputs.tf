output "id" {
  description = "The ID of the Function App Function."
  value       = azurerm_function_app_function.function.id
}

output "name" {
  description = "The Name of the Function."
  value       = azurerm_function_app_function.function.name
}

output "url" {
  description = "The invocation URL of the function, if HTTP triggered."
  value       = azurerm_function_app_function.function.url
}

output "function" {
  description = "The full Azure Function App Function resource object."
  value       = azurerm_function_app_function.function
}
