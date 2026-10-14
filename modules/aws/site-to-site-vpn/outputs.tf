output "customer_gateway_id" {
  description = "The ID of the Customer Gateway (created or referenced)."
  value       = local.customer_gateway_id
}

output "customer_gateway_arn" {
  description = "The ARN of the Customer Gateway, if created by this module."
  value       = try(aws_customer_gateway.this[0].arn, null)
}

output "vpn_connection_id" {
  description = "The ID of the VPN Connection."
  value       = aws_vpn_connection.this.id
}

output "vpn_connection_arn" {
  description = "The ARN of the VPN Connection."
  value       = aws_vpn_connection.this.arn
}

output "customer_gateway_configuration" {
  description = "The configuration information for the VPN connection's customer gateway, in the native XML format."
  value       = aws_vpn_connection.this.customer_gateway_configuration
  sensitive   = true
}

output "tunnel1_address" {
  description = "The public IP address of the first VPN tunnel."
  value       = aws_vpn_connection.this.tunnel1_address
}

output "tunnel2_address" {
  description = "The public IP address of the second VPN tunnel."
  value       = aws_vpn_connection.this.tunnel2_address
}

output "tunnel1_preshared_key" {
  description = "The pre-shared key of the first VPN tunnel."
  value       = aws_vpn_connection.this.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel2_preshared_key" {
  description = "The pre-shared key of the second VPN tunnel."
  value       = aws_vpn_connection.this.tunnel2_preshared_key
  sensitive   = true
}

output "routes" {
  description = "Map of static route keys to their aws_vpn_connection_route resource IDs."
  value       = { for k, v in aws_vpn_connection_route.this : k => v.id }
}
