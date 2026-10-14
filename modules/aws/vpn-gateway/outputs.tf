output "id" {
  description = "The ID of the Virtual Private Gateway."
  value       = aws_vpn_gateway.this.id
}

output "arn" {
  description = "The ARN of the Virtual Private Gateway."
  value       = aws_vpn_gateway.this.arn
}

output "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway."
  value       = aws_vpn_gateway.this.amazon_side_asn
}

output "route_propagation_ids" {
  description = "Map of route table IDs to their route propagation resource IDs."
  value       = { for k, v in aws_vpn_gateway_route_propagation.this : k => v.id }
}
