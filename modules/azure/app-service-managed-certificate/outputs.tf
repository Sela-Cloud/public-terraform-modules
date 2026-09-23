output "id" {
  description = "The ID of the App Service Managed Certificate."
  value       = azurerm_app_service_managed_certificate.certificate.id
}

output "canonical_name" {
  description = "The Canonical Name of the Certificate."
  value       = azurerm_app_service_managed_certificate.certificate.canonical_name
}

output "expiration_date" {
  description = "The expiration date of the Certificate."
  value       = azurerm_app_service_managed_certificate.certificate.expiration_date
}

output "friendly_name" {
  description = "The friendly name of the Certificate."
  value       = azurerm_app_service_managed_certificate.certificate.friendly_name
}

output "host_names" {
  description = "The list of Host Names for the Certificate."
  value       = azurerm_app_service_managed_certificate.certificate.host_names
}

output "issue_date" {
  description = "The Start date for the Certificate."
  value       = azurerm_app_service_managed_certificate.certificate.issue_date
}

output "issuer" {
  description = "The issuer of the Certificate."
  value       = azurerm_app_service_managed_certificate.certificate.issuer
}

output "subject_name" {
  description = "The Subject Name for the Certificate."
  value       = azurerm_app_service_managed_certificate.certificate.subject_name
}

output "thumbprint" {
  description = "The Certificate Thumbprint."
  value       = azurerm_app_service_managed_certificate.certificate.thumbprint
}

output "app_service_managed_certificate" {
  description = "The full Azure App Service Managed Certificate resource object."
  value       = azurerm_app_service_managed_certificate.certificate
}
