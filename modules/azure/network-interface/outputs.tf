output "id" {
  description = "The ID of the Network Interface."
  value       = azurerm_network_interface.nic.id
}

output "name" {
  description = "The Name of the Network Interface."
  value       = azurerm_network_interface.nic.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Network Interface was created."
  value       = azurerm_network_interface.nic.resource_group_name
}

output "location" {
  description = "The Azure Region of the Network Interface."
  value       = azurerm_network_interface.nic.location
}

output "applied_dns_servers" {
  description = "If the Virtual Machine using this Network Interface is part of an Availability Set, then this list contains the union of all DNS servers from all Network Interfaces that are part of that Availability Set."
  value       = azurerm_network_interface.nic.applied_dns_servers
}

output "internal_domain_name_suffix" {
  description = "Even if internal_dns_name_label is not specified, a DNS entry is created for the resource. This attribute provides the internal domain name suffix."
  value       = azurerm_network_interface.nic.internal_domain_name_suffix
}

output "mac_address" {
  description = "The Media Access Control (MAC) address of the Network Interface."
  value       = azurerm_network_interface.nic.mac_address
}

output "private_ip_address" {
  description = "The first private IP address of the Network Interface."
  value       = azurerm_network_interface.nic.private_ip_address
}

output "private_ip_addresses" {
  description = "The list of private IP addresses of the Network Interface."
  value       = azurerm_network_interface.nic.private_ip_addresses
}

output "virtual_machine_id" {
  description = "The ID of the Virtual Machine with which this Network Interface is associated."
  value       = azurerm_network_interface.nic.virtual_machine_id
}

output "network_interface" {
  description = "The full Azure Network Interface resource object."
  value       = azurerm_network_interface.nic
}

output "network_security_group_association" {
  description = "The Network Interface and Network Security Group association object (if created)."
  value       = try(azurerm_network_interface_security_group_association.nsg_association[0], null)
}
