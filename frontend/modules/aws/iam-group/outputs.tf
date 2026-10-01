output "id" {
  description = "The group's name."
  value       = aws_iam_group.this.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS for this group."
  value       = aws_iam_group.this.arn
}

output "name" {
  description = "The group's name."
  value       = aws_iam_group.this.name
}

output "unique_id" {
  description = "The unique ID assigned by AWS for this group."
  value       = aws_iam_group.this.unique_id
}

output "policy_attachments" {
  description = "A list of policy ARNs attached to the IAM group."
  value       = [for k, v in aws_iam_group_policy_attachment.this : v.policy_arn]
}
