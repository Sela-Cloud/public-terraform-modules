################################################################################
# AWS Network ACL Outputs
################################################################################

output "id" {
  description = "The ID of the Network ACL."
  value       = aws_network_acl.this.id
}

output "arn" {
  description = "The ARN of the Network ACL."
  value       = aws_network_acl.this.arn
}

output "owner_id" {
  description = "The ID of the AWS account that owns the Network ACL."
  value       = aws_network_acl.this.owner_id
}

output "vpc_id" {
  description = "The VPC ID associated with the Network ACL."
  value       = aws_network_acl.this.vpc_id
}

output "subnet_ids" {
  description = "The list of Subnet IDs associated with the Network ACL."
  value       = aws_network_acl.this.subnet_ids
}

output "ingress" {
  description = "The set of ingress rules configured on the Network ACL."
  value       = aws_network_acl.this.ingress
}

output "egress" {
  description = "The set of egress rules configured on the Network ACL."
  value       = aws_network_acl.this.egress
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_network_acl.this.tags_all
}
