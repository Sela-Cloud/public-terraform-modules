output "bucket_id" {
  description = "ID (name) of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "object_key" {
  description = "Key of the created S3 object."
  value       = aws_s3_object.this.key
}

output "object_version_id" {
  description = "Version ID of the created S3 object."
  value       = aws_s3_object.this.version_id
}

output "object_ownership" {
  description = "Object ownership configuration of the S3 bucket."
  value       = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership
}

output "public_access_block_enabled" {
  description = "Whether public access blocking is configured for the S3 bucket."
  value       = true
}