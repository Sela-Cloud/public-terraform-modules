output "bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the bucket. Will be of form arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "object_id" {
  description = "The key of the created S3 object."
  value       = aws_s3_object.this.id
}

output "object_version_id" {
  description = "The unique version ID of the created object, if versioning is enabled."
  value       = aws_s3_object.this.version_id
}

output "website_endpoint" {
  description = "The website endpoint URL if website hosting is enabled."
  value       = try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null)
}

output "website_domain" {
  description = "The domain of the website endpoint if website hosting is enabled."
  value       = try(aws_s3_bucket_website_configuration.this[0].website_domain, null)
}