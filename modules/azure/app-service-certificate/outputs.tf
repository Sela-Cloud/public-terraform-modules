output "id" {
  description = "The ID of the App Service Certificate."
  value       = azurerm_app_service_certificate.certificate.id
}

output "name" {
  description = "The name of the App Service Certificate."
  value       = azurerm_app_service_certificate.certificate.name
}

output "expiration_date" {
  description = "The expiration date for the certificate."
  value       = azurerm_app_service_certificate.certificate.expiration_date
}

output "friendly_name" {
  description = "The friendly name of the certificate."
  value       = azurerm_app_service_certificate.certificate.friendly_name
}

output "host_names" {
  description = "List of host names the certificate is valid for."
  value       = azurerm_app_service_certificate.certificate.host_names
}

output "hosting_environment_profile_id" {
  description = "The ID of the App Service Environment hosting environment profile."
  value       = azurerm_app_service_certificate.certificate.hosting_environment_profile_id
}

output "issue_date" {
  description = "The date the certificate was issued."
  value       = azurerm_app_service_certificate.certificate.issue_date
}

output "issuer" {
  description = "The issuer of the certificate."
  value       = azurerm_app_service_certificate.certificate.issuer
}

output "subject_name" {
  description = "The subject name of the certificate."
  value       = azurerm_app_service_certificate.certificate.subject_name
}

output "thumbprint" {
  description = "The thumbprint of the certificate."
  value       = azurerm_app_service_certificate.certificate.thumbprint
}

output "app_service_certificate" {
  description = "The full Azure App Service Certificate resource object."
  value       = azurerm_app_service_certificate.certificate
  sensitive   = true
}
