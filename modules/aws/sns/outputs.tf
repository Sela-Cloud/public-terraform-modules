output "id" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.this.id
}

output "arn" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.this.arn
}

output "name" {
  description = "The name of the SNS topic."
  value       = aws_sns_topic.this.name
}

output "owner" {
  description = "The AWS Account ID of the SNS topic owner."
  value       = aws_sns_topic.this.owner
}

output "policy_id" {
  description = "The ID of the topic policy, if created."
  value       = try(aws_sns_topic_policy.this[0].id, null)
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_sns_topic.this.tags_all
}
