output "id" {
  description = "The ID of the Application Security Group."
  value       = azurerm_application_security_group.asg.id
}

output "name" {
  description = "The Name of the Application Security Group."
  value       = azurerm_application_security_group.asg.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Application Security Group was created."
  value       = azurerm_application_security_group.asg.resource_group_name
}

output "location" {
  description = "The Azure Region of the Application Security Group."
  value       = azurerm_application_security_group.asg.location
}

output "tags" {
  description = "The tags assigned to the Application Security Group."
  value       = azurerm_application_security_group.asg.tags
}

output "network_interface_association_ids" {
  description = "Map of Network Interface IDs to their association resource IDs."
  value       = { for k, v in azurerm_network_interface_application_security_group_association.nic_association : k => v.id }
}

output "application_security_group" {
  description = "The full Azure Application Security Group resource object."
  value       = azurerm_application_security_group.asg
}
