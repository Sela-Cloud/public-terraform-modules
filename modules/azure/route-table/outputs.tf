output "id" {
  description = "The ID of the Route Table."
  value       = azurerm_route_table.route_table.id
}

output "name" {
  description = "The Name of the Route Table."
  value       = azurerm_route_table.route_table.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Route Table was created."
  value       = azurerm_route_table.route_table.resource_group_name
}

output "location" {
  description = "The Azure Region of the Route Table."
  value       = azurerm_route_table.route_table.location
}

output "bgp_route_propagation_enabled" {
  description = "Whether BGP route propagation is enabled for the Route Table."
  value       = azurerm_route_table.route_table.bgp_route_propagation_enabled
}

output "subnets" {
  description = "The collection of Subnets associated with this Route Table."
  value       = azurerm_route_table.route_table.subnets
}

output "routes" {
  description = "The list of routes configured in the Route Table."
  value       = azurerm_route_table.route_table.route
}

output "route_table" {
  description = "The full Azure Route Table resource object."
  value       = azurerm_route_table.route_table
}

output "subnet_associations" {
  description = "Map of subnet route table associations created."
  value       = azurerm_subnet_route_table_association.subnet_association
}
