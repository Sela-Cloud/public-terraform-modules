################################################################################
# AWS EBS Volume Outputs
################################################################################

output "id" {
  description = "The ID of the EBS volume."
  value       = aws_ebs_volume.this.id
}

output "arn" {
  description = "The ARN of the EBS volume."
  value       = aws_ebs_volume.this.arn
}

output "size" {
  description = "The size of the volume in GiBs."
  value       = aws_ebs_volume.this.size
}

output "type" {
  description = "The type of EBS volume."
  value       = aws_ebs_volume.this.type
}

output "availability_zone" {
  description = "The Availability Zone of the EBS volume."
  value       = aws_ebs_volume.this.availability_zone
}
