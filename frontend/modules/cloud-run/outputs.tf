output "cloud_run_service_names" {
  value       = { for key, cr in module.cloud_run_v2 : key => cr.service_name }
  description = "Name of the created services"
}
