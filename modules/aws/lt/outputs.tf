output "id" {
  description = "The ID of the launch template."
  value       = aws_launch_template.this.id
}

output "arn" {
  description = "The ARN of the launch template."
  value       = aws_launch_template.this.arn
}

output "name" {
  description = "The name of the launch template."
  value       = aws_launch_template.this.name
}

output "default_version" {
  description = "The default version of the launch template."
  value       = aws_launch_template.this.default_version
}

output "latest_version" {
  description = "The latest version of the launch template."
  value       = aws_launch_template.this.latest_version
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_launch_template.this.tags_all
}
