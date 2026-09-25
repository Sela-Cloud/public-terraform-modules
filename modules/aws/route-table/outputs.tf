################################################################################
# AWS Route Table Outputs
################################################################################

output "route_tables" {
  description = "Map of all created aws_route_table resources keyed by route table identifier."
  value       = aws_route_table.this
}

output "route_table_ids" {
  description = "Map of route table identifiers to their corresponding route table IDs."
  value       = { for k, v in aws_route_table.this : k => v.id }
}

output "route_table_arns" {
  description = "Map of route table identifiers to their corresponding route table ARNs."
  value       = { for k, v in aws_route_table.this : k => v.arn }
}

output "subnet_associations" {
  description = "Map of created aws_route_table_association resources for subnets, keyed by '<route_table_key>.<subnet_id>'."
  value       = aws_route_table_association.subnet
}

output "subnet_association_ids" {
  description = "Map of '<route_table_key>.<subnet_id>' to their corresponding association IDs."
  value       = { for k, v in aws_route_table_association.subnet : k => v.id }
}

output "subnet_association_ids_by_route_table" {
  description = "Map of route table identifiers to lists of subnet association IDs."
  value = {
    for rt_key, rt in var.route_tables : rt_key => [
      for k, v in aws_route_table_association.subnet : v.id
      if startswith(k, "${rt_key}.")
    ]
  }
}

output "gateway_associations" {
  description = "Map of created aws_route_table_association resources for gateways, keyed by route table identifier."
  value       = aws_route_table_association.gateway
}

output "gateway_association_ids" {
  description = "Map of route table identifiers to their corresponding gateway association IDs."
  value       = { for k, v in aws_route_table_association.gateway : k => v.id }
}

output "routes" {
  description = "Map of all created aws_route resources, keyed by '<route_table_key>.<route_key>'."
  value       = aws_route.this
}

output "route_ids" {
  description = "Map of '<route_table_key>.<route_key>' to their corresponding route IDs."
  value       = { for k, v in aws_route.this : k => v.id }
}

output "route_ids_by_route_table" {
  description = "Map of route table identifiers to lists of route IDs."
  value = {
    for rt_key, rt in var.route_tables : rt_key => [
      for k, v in aws_route.this : v.id
      if startswith(k, "${rt_key}.")
    ]
  }
}
