################################################################################
# AWS ECR/ACR Repository Outputs
################################################################################

output "id" {
  description = "The registry name / ID of the repository."
  value       = aws_ecr_repository.this.id
}

output "arn" {
  description = "The ARN of the repository."
  value       = aws_ecr_repository.this.arn
}

output "name" {
  description = "The name of the repository."
  value       = aws_ecr_repository.this.name
}

output "registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.this.registry_id
}

output "repository_url" {
  description = "The URL of the repository."
  value       = aws_ecr_repository.this.repository_url
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_ecr_repository.this.tags_all
}
