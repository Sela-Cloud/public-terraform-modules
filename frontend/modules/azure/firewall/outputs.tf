output "firewalls" {
  description = "A map of all created Azure Firewall module instances."
  value       = module.firewall
}

output "firewall_ids" {
  description = "A map of Firewall names to their respective resource IDs."
  value       = { for k, v in module.firewall : k => v.id }
}

output "firewall_ip_configurations" {
  description = "A map of Firewall names to their respective IP configuration blocks."
  value       = { for k, v in module.firewall : k => v.ip_configuration }
}
