output "frontdoor" {
  description = "A map of created Azure Front Door profiles and their attributes."
  value       = module.frontdoor
}

output "frontdoor_ids" {
  description = "A map of Front Door profile names to their resource IDs."
  value       = { for k, v in module.frontdoor : k => v.id }
}

output "frontdoor_endpoints" {
  description = "A map of Front Door profile names to their endpoints map."
  value       = { for k, v in module.frontdoor : k => v.endpoints }
}
