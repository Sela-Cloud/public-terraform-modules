output "id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "arn" {
  description = "The ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "name" {
  description = "The name given to the EC2 instance."
  value       = var.name
}

output "ami" {
  description = "The AMI ID used to launch the EC2 instance."
  value       = aws_instance.this.ami
}

output "instance_type" {
  description = "The instance type of the EC2 instance."
  value       = aws_instance.this.instance_type
}

output "availability_zone" {
  description = "The availability zone of the EC2 instance."
  value       = aws_instance.this.availability_zone
}

output "placement_group" {
  description = "The placement group for the EC2 instance."
  value       = aws_instance.this.placement_group
}

output "public_ip" {
  description = "The public IP address assigned to the instance (or Elastic IP if enabled)."
  value       = var.enable_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = aws_instance.this.private_ip
}

output "public_dns" {
  description = "The public DNS name assigned to the instance (or Elastic IP public DNS if enabled)."
  value       = var.enable_eip ? aws_eip.this[0].public_dns : aws_instance.this.public_dns
}

output "private_dns" {
  description = "The private DNS name assigned to the instance."
  value       = aws_instance.this.private_dns
}

output "subnet_id" {
  description = "The VPC Subnet ID the instance was launched in."
  value       = aws_instance.this.subnet_id
}

output "vpc_security_group_ids" {
  description = "The security group IDs associated with the instance."
  value       = aws_instance.this.vpc_security_group_ids
}

output "primary_network_interface_id" {
  description = "The ID of the instance's primary network interface."
  value       = aws_instance.this.primary_network_interface_id
}

output "iam_instance_profile" {
  description = "The IAM instance profile assigned to the instance."
  value       = aws_instance.this.iam_instance_profile
}

output "root_block_device" {
  description = "Root block device configuration and attributes."
  value       = aws_instance.this.root_block_device
}

output "ebs_block_devices" {
  description = "Map of secondary EBS volumes created and attached to the instance."
  value       = aws_ebs_volume.this
}

output "eip_public_ip" {
  description = "The Elastic IP public address if enabled."
  value       = try(aws_eip.this[0].public_ip, null)
}

output "eip_allocation_id" {
  description = "The Elastic IP allocation ID if enabled."
  value       = try(aws_eip.this[0].id, null)
}
