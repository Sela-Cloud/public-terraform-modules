output "id" {
  value       = aws_secretsmanager_secret.this.id
  description = "The Amazon Resource Name (ARN) of the secret."
}

output "arn" {
  value       = aws_secretsmanager_secret.this.arn
  description = "The Amazon Resource Name (ARN) of the secret."
}

output "name" {
  value       = aws_secretsmanager_secret.this.name
  description = "The friendly name of the secret."
}

output "replica_attributes" {
  value       = aws_secretsmanager_secret.this.replica
  description = "Attributes of the secret replicas, including status and status messages."
}

output "rotation_enabled" {
  value       = var.set_rotation
  description = "Whether automatic rotation is configured for this secret."
}
