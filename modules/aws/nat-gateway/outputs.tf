output "id" {
  description = "The ID of the NAT Gateway."
  value       = aws_nat_gateway.this.id
}

output "allocation_id" {
  description = "The Allocation ID of the Elastic IP address for the NAT Gateway (zonal)."
  value       = aws_nat_gateway.this.allocation_id
}

output "association_id" {
  description = "The association ID of the Elastic IP address that's associated with the NAT Gateway (zonal)."
  value       = aws_nat_gateway.this.association_id
}

output "network_interface_id" {
  description = "The ID of the network interface associated with the NAT Gateway (zonal)."
  value       = aws_nat_gateway.this.network_interface_id
}

output "public_ip" {
  description = "The Elastic IP address associated with the NAT Gateway (zonal)."
  value       = aws_nat_gateway.this.public_ip
}

output "route_table_id" {
  description = "The ID of the automatically created route table (regional)."
  value       = aws_nat_gateway.this.route_table_id
}

output "auto_provision_zones" {
  description = "Indicates whether AWS automatically manages AZ coverage (regional)."
  value       = aws_nat_gateway.this.auto_provision_zones
}

output "auto_scaling_ips" {
  description = "Indicates whether AWS automatically allocates additional Elastic IP addresses (regional)."
  value       = aws_nat_gateway.this.auto_scaling_ips
}

output "regional_nat_gateway_address" {
  description = "Information about the IP addresses and network interfaces associated with the regional NAT gateway."
  value       = aws_nat_gateway.this.regional_nat_gateway_address
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_nat_gateway.this.tags_all
}
