output "application_gateways" {
  description = "A map of all created Azure Application Gateway module instances."
  value       = module.application_gateway
}

output "application_gateway_ids" {
  description = "A map of Application Gateway names to their respective resource IDs."
  value       = { for k, v in module.application_gateway : k => v.id }
}
