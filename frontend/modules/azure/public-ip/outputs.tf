output "public_ips" {
  description = "Map of created Public IPs and their attributes."
  value       = module.public_ip
}

output "public_ip_ids" {
  description = "Map of Public IP names to their Azure resource IDs."
  value       = { for k, v in module.public_ip : k => v.id }
}

output "public_ip_addresses" {
  description = "Map of Public IP names to their allocated IP addresses."
  value       = { for k, v in module.public_ip : k => v.ip_address }
}
