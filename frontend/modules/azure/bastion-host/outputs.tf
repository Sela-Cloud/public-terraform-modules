output "bastion_hosts" {
  description = "A map of all created Azure Bastion Host module instances."
  value       = module.bastion_host
}

output "bastion_host_ids" {
  description = "A map of Bastion Host names to their respective resource IDs."
  value       = { for k, v in module.bastion_host : k => v.id }
}

output "bastion_host_dns_names" {
  description = "A map of Bastion Host names to their respective fully qualified domain names (FQDNs)."
  value       = { for k, v in module.bastion_host : k => v.dns_name }
}
