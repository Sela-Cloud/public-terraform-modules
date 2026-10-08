output "frontdoors" {
  description = "A map of all created Azure Front Door module instances."
  value       = module.frontdoor
}

output "frontdoor_ids" {
  description = "A map of Front Door names to their respective resource IDs."
  value       = { for k, v in module.frontdoor : k => v.id }
}

output "frontdoor_cnames" {
  description = "A map of Front Door names to their respective CNAMEs."
  value       = { for k, v in module.frontdoor : k => v.cname }
}
