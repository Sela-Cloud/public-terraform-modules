output "load_balancer_ip_addresses" {
  description = "Internal IP address of each load balancer, keyed by resource name."
  value       = { for key, lb in module.regional_internal_lb : key => lb.load_balancer_ip_address }
}

output "url_map_ids" {
  description = "URL map ID of each load balancer, keyed by resource name."
  value       = { for key, lb in module.regional_internal_lb : key => lb.url_map_id }
}
