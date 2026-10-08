################################################################################
# Lambda Function Outputs
################################################################################

output "function_name" {
  description = "Unique name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "Amazon Resource Name (ARN) identifying your Lambda Function."
  value       = aws_lambda_function.this.arn
}

output "function_id" {
  description = "The ID of the Lambda function."
  value       = aws_lambda_function.this.id
}

output "invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway or other services."
  value       = aws_lambda_function.this.invoke_arn
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version (if published)."
  value       = aws_lambda_function.this.qualified_arn
}

output "qualified_invoke_arn" {
  description = "Qualified ARN to be used for invoking Lambda Function from API Gateway."
  value       = aws_lambda_function.this.qualified_invoke_arn
}

output "version" {
  description = "Latest published version of your Lambda Function."
  value       = aws_lambda_function.this.version
}

output "source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip package."
  value       = aws_lambda_function.this.source_code_hash
}

output "source_code_size" {
  description = "The size in bytes of the function .zip file."
  value       = aws_lambda_function.this.source_code_size
}

output "signing_profile_version_arn" {
  description = "ARN of the signing profile version."
  value       = aws_lambda_function.this.signing_profile_version_arn
}

output "signing_job_arn" {
  description = "ARN of the signing job."
  value       = aws_lambda_function.this.signing_job_arn
}

################################################################################
# IAM Execution Role Outputs
################################################################################

output "role_arn" {
  description = "ARN of the IAM role attached to the Lambda function."
  value       = local.role_arn
}

output "role_name" {
  description = "Name of the IAM role created for the Lambda function (if created)."
  value       = try(aws_iam_role.this[0].name, null)
}

output "role_id" {
  description = "ID of the IAM role created for the Lambda function (if created)."
  value       = try(aws_iam_role.this[0].id, null)
}

################################################################################
# CloudWatch Log Group Outputs
################################################################################

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group created for the Lambda function."
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group created for the Lambda function."
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

################################################################################
# Function URL Outputs
################################################################################

output "function_url" {
  description = "The HTTP URL endpoint assigned to the function (if Function URL is enabled)."
  value       = try(aws_lambda_function_url.this[0].function_url, null)
}

output "function_url_id" {
  description = "The ID of the function URL."
  value       = try(aws_lambda_function_url.this[0].id, null)
}

################################################################################
# Aliases Outputs
################################################################################

output "aliases" {
  description = "Map of created Lambda Aliases and their attributes."
  value       = aws_lambda_alias.this
}

################################################################################
# Layer Versions Outputs
################################################################################

output "layers" {
  description = "Map of created Lambda Layer Versions."
  value       = aws_lambda_layer_version.this
}

################################################################################
# Code Signing Config Outputs
################################################################################

output "code_signing_config_arn" {
  description = "The ARN of the Code Signing Configuration (if created)."
  value       = try(aws_lambda_code_signing_config.this[0].arn, null)
}

output "code_signing_config_id" {
  description = "The ID of the Code Signing Configuration (if created)."
  value       = try(aws_lambda_code_signing_config.this[0].id, null)
}
