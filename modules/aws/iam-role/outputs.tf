output "id" {
  description = "The name of the IAM role."
  value       = aws_iam_role.this.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role."
  value       = aws_iam_role.this.arn
}

output "name" {
  description = "The name of the IAM role."
  value       = aws_iam_role.this.name
}

output "unique_id" {
  description = "Stable and unique string identifying the IAM role."
  value       = aws_iam_role.this.unique_id
}

output "create_date" {
  description = "Creation date of the IAM role in RFC 3339 format."
  value       = aws_iam_role.this.create_date
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_iam_role.this.tags_all
}
