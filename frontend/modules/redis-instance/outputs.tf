output "instance_ids" {
  description = "Full resource name of each instance, keyed by resource name."
  value       = { for key, i in module.redis_instance : key => i.id }
}

output "hosts" {
  description = "Redis endpoint hostname/IP of each instance, keyed by resource name."
  value       = { for key, i in module.redis_instance : key => i.host }
}
