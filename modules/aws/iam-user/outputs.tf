output "id" {
  description = "The user's name."
  value       = aws_iam_user.this.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS for this user."
  value       = aws_iam_user.this.arn
}

output "name" {
  description = "The user's name."
  value       = aws_iam_user.this.name
}

output "unique_id" {
  description = "The unique ID assigned by AWS for this user."
  value       = aws_iam_user.this.unique_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_iam_user.this.tags_all
}
