output "id" {
  description = "The ID of the Virtual Machine."
  value       = azurerm_virtual_machine.vm.id
}

output "name" {
  description = "The Name of the Virtual Machine."
  value       = azurerm_virtual_machine.vm.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Virtual Machine was created."
  value       = azurerm_virtual_machine.vm.resource_group_name
}

output "location" {
  description = "The Azure Region of the Virtual Machine."
  value       = azurerm_virtual_machine.vm.location
}

output "vm_size" {
  description = "The size/SKU of the Virtual Machine."
  value       = azurerm_virtual_machine.vm.vm_size
}

output "network_interface_ids" {
  description = "The list of Network Interface IDs attached to the Virtual Machine."
  value       = azurerm_virtual_machine.vm.network_interface_ids
}

output "identity" {
  description = "The Managed Service Identity configuration of the Virtual Machine."
  value       = azurerm_virtual_machine.vm.identity
}

output "virtual_machine" {
  description = "The full Azure Virtual Machine resource object."
  value       = azurerm_virtual_machine.vm
}
