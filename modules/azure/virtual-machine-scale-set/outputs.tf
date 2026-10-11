output "id" {
  description = "The Virtual Machine Scale Set ID."
  value       = azurerm_virtual_machine_scale_set.vmss.id
}

output "name" {
  description = "The Name of the Virtual Machine Scale Set."
  value       = azurerm_virtual_machine_scale_set.vmss.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Scale Set was created."
  value       = azurerm_virtual_machine_scale_set.vmss.resource_group_name
}

output "location" {
  description = "The Azure Region where the Scale Set exists."
  value       = azurerm_virtual_machine_scale_set.vmss.location
}

output "sku" {
  description = "The SKU specification and capacity of the Virtual Machine Scale Set."
  value       = azurerm_virtual_machine_scale_set.vmss.sku
}

output "identity" {
  description = "The Managed Service Identity block associated with the Scale Set."
  value       = azurerm_virtual_machine_scale_set.vmss.identity
}

output "network_profile" {
  description = "The Network Profile block configured on the Virtual Machine Scale Set."
  value       = azurerm_virtual_machine_scale_set.vmss.network_profile
}

output "virtual_machine_scale_set" {
  description = "The full Azure Virtual Machine Scale Set resource object."
  value       = azurerm_virtual_machine_scale_set.vmss
}
