output "id" {
  description = "The name of the DynamoDB table (its ID)."
  value       = aws_dynamodb_table.this.id
}

output "arn" {
  description = "The ARN of the DynamoDB table."
  value       = aws_dynamodb_table.this.arn
}

output "name" {
  description = "The name of the DynamoDB table."
  value       = aws_dynamodb_table.this.name
}

output "stream_arn" {
  description = "The ARN of the table stream, if stream_enabled is true."
  value       = try(aws_dynamodb_table.this.stream_arn, null)
}

output "stream_label" {
  description = "A timestamp of the table stream's creation, if stream_enabled is true."
  value       = try(aws_dynamodb_table.this.stream_label, null)
}

output "replica" {
  description = "The table's Global Tables v2 replicas and their computed ARNs/stream details."
  value       = aws_dynamodb_table.this.replica
}

output "contributor_insights_id" {
  description = "The ID of the Contributor Insights resource, if contributor_insights_enabled is true."
  value       = try(aws_dynamodb_contributor_insights.this[0].id, null)
}

output "autoscaling_target_resource_ids" {
  description = "Map of autoscaling entry keys to their Application Auto Scaling resource IDs."
  value       = { for k, v in aws_appautoscaling_target.this : k => v.resource_id }
}
