output "dns_resource_records" {
  description = "The DNS record each authorization needs added to its domain's DNS zone, keyed by resource name."
  value       = { for key, auth in module.dns_authorization : key => auth.dns_resource_record }
}
