output "load_balancer_ip_addresses" {
  description = "IP address of each load balancer, keyed by resource name."
  value       = { for key, alb in module.global_external_alb : key => alb.load_balancer_ip_address }
}

output "url_map_ids" {
  description = "URL map ID of each load balancer, keyed by resource name."
  value       = { for key, alb in module.global_external_alb : key => alb.url_map_id }
}
