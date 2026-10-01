output "id" {
  description = "The ID of the Load Balancer."
  value       = azurerm_lb.lb.id
}

output "name" {
  description = "The name of the Load Balancer."
  value       = azurerm_lb.lb.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Load Balancer was created."
  value       = azurerm_lb.lb.resource_group_name
}

output "location" {
  description = "The Azure Region of the Load Balancer."
  value       = azurerm_lb.lb.location
}

output "sku" {
  description = "The SKU of the Load Balancer."
  value       = azurerm_lb.lb.sku
}

output "sku_tier" {
  description = "The SKU tier of the Load Balancer."
  value       = azurerm_lb.lb.sku_tier
}

output "frontend_ip_configurations" {
  description = "The frontend IP configurations of the Load Balancer."
  value       = azurerm_lb.lb.frontend_ip_configuration
}

output "backend_address_pools" {
  description = "Map of created backend address pools."
  value       = azurerm_lb_backend_address_pool.backend_pool
}

output "backend_address_pool_ids" {
  description = "Map of backend address pool names to their Azure resource IDs."
  value       = { for k, v in azurerm_lb_backend_address_pool.backend_pool : k => v.id }
}

output "health_probes" {
  description = "Map of created health probes."
  value       = azurerm_lb_probe.probe
}

output "health_probe_ids" {
  description = "Map of health probe names to their Azure resource IDs."
  value       = { for k, v in azurerm_lb_probe.probe : k => v.id }
}

output "load_balancing_rules" {
  description = "Map of created load balancing rules."
  value       = azurerm_lb_rule.rule
}

output "load_balancing_rule_ids" {
  description = "Map of load balancing rule names to their Azure resource IDs."
  value       = { for k, v in azurerm_lb_rule.rule : k => v.id }
}

output "inbound_nat_rules" {
  description = "Map of created inbound NAT rules."
  value       = azurerm_lb_nat_rule.nat_rule
}

output "inbound_nat_rule_ids" {
  description = "Map of inbound NAT rule names to their Azure resource IDs."
  value       = { for k, v in azurerm_lb_nat_rule.nat_rule : k => v.id }
}

output "tags" {
  description = "The tags assigned to the Load Balancer."
  value       = azurerm_lb.lb.tags
}

output "lb" {
  description = "The full Azure Load Balancer resource object."
  value       = azurerm_lb.lb
}
