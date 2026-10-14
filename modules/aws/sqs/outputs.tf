output "id" {
  description = "The URL of the created Amazon SQS queue."
  value       = aws_sqs_queue.this.id
}

output "arn" {
  description = "The ARN of the SQS queue."
  value       = aws_sqs_queue.this.arn
}

output "url" {
  description = "The URL of the created Amazon SQS queue."
  value       = aws_sqs_queue.this.url
}

output "name" {
  description = "The name of the SQS queue."
  value       = aws_sqs_queue.this.name
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_sqs_queue.this.tags_all
}
