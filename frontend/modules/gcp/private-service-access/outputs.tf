output "reserved_ranges" {
  value = { for key, access in module.private_service_access : key => access.reserved_range_name }
}

output "connections" {
  value = { for key, access in module.private_service_access : key => access.connection }
}
