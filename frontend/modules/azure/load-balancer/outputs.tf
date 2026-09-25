output "load_balancers" {
  description = "Map of created Load Balancers and their attributes."
  value       = module.load_balancer
}

output "load_balancer_ids" {
  description = "Map of Load Balancer names to their Azure resource IDs."
  value       = { for k, v in module.load_balancer : k => v.id }
}
