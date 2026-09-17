output "load_balancer_ip_address" {
  description = "The IP address the load balancer serves on."
  value       = local.lb_ip_address
}

output "backend_service_names" {
  description = "Names of the created backend services."
  value       = [for svc in google_compute_backend_service.this : svc.name]
}

output "backend_bucket_names" {
  description = "Names of the created backend buckets."
  value       = [for bkt in google_compute_backend_bucket.this : bkt.name]
}

output "url_map_id" {
  description = "ID of the load balancer's URL map."
  value       = google_compute_url_map.this.id
}

output "cloud_run_neg_names" {
  description = "Names of the serverless NEGs created for Cloud Run backends, keyed by backend service name."
  value       = { for key, neg in google_compute_region_network_endpoint_group.cloud_run : key => neg.name }
}
