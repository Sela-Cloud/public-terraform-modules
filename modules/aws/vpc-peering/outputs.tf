################################################################################
# AWS VPC Peering Connection Outputs
################################################################################

output "id" {
  description = "The ID of the VPC Peering Connection."
  value       = aws_vpc_peering_connection.this.id
}

output "accept_status" {
  description = "The status of the VPC Peering Connection request."
  value       = aws_vpc_peering_connection.this.accept_status
}

output "vpc_id" {
  description = "The ID of the requester VPC."
  value       = aws_vpc_peering_connection.this.vpc_id
}

output "peer_vpc_id" {
  description = "The ID of the accepter VPC."
  value       = aws_vpc_peering_connection.this.peer_vpc_id
}
