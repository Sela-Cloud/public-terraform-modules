output "id" {
  description = "The ID of the subnet."
  value       = aws_subnet.this.id
}

output "arn" {
  description = "The ARN of the subnet."
  value       = aws_subnet.this.arn
}

output "vpc_id" {
  description = "The VPC ID."
  value       = aws_subnet.this.vpc_id
}

output "cidr_block" {
  description = "The IPv4 CIDR block of the subnet."
  value       = aws_subnet.this.cidr_block
}

output "availability_zone" {
  description = "The availability zone of the subnet."
  value       = aws_subnet.this.availability_zone
}

output "availability_zone_id" {
  description = "The availability zone ID of the subnet."
  value       = aws_subnet.this.availability_zone_id
}

output "ipv6_cidr_block" {
  description = "The IPv6 network range for the subnet."
  value       = aws_subnet.this.ipv6_cidr_block
}

output "ipv6_cidr_block_association_id" {
  description = "The association ID for the IPv6 CIDR block."
  value       = aws_subnet.this.ipv6_cidr_block_association_id
}

output "owner_id" {
  description = "The ID of the AWS account that owns the subnet."
  value       = aws_subnet.this.owner_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_subnet.this.tags_all
}
