output "id" {
  description = "The ID of the Bastion Host."
  value       = azurerm_bastion_host.bastion.id
}

output "name" {
  description = "The Name of the Bastion Host."
  value       = azurerm_bastion_host.bastion.name
}

output "dns_name" {
  description = "The fully qualified domain name (FQDN) for the Bastion Host."
  value       = azurerm_bastion_host.bastion.dns_name
}

output "bastion_host" {
  description = "The full Azure Bastion Host resource object."
  value       = azurerm_bastion_host.bastion
}
