output "route_tables" {
  description = "Map of created Route Tables and their attributes."
  value       = module.route_table
}

output "route_table_ids" {
  description = "Map of Route Table names to their Azure resource IDs."
  value       = { for k, v in module.route_table : k => v.id }
}
