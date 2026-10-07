variable "secret_id" {
  type        = string
  description = "Friendly name of the secret."
}

variable "description" {
  type        = string
  default     = null
  description = "A description of the secret."
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "ARN or Id of the AWS KMS key to protect the primary secret. If null, uses the default aws/secretsmanager key."
}

variable "recovery_window_in_days" {
  type        = number
  default     = 30
  description = "Number of days AWS Secrets Manager waits before permanently deleting the secret (7 to 30 days, or 0 to delete immediately without recovery)."

  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "recovery_window_in_days must be 0 or between 7 and 30."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Key-value map of resource tags (replaces labels/annotations)."
}

# Replication Configurations
variable "custom_replication" {
  type        = bool
  default     = false
  description = "Set to true to replicate the secret into other target regions."
}

variable "replica_regions" {
  type = list(object({
    region     = string
    kms_key_id = optional(string, null)
  }))
  default     = []
  description = "AWS Regions to replicate the secret into, along with optional custom KMS keys."
}

# Rotation Configurations
variable "set_rotation" {
  type        = bool
  default     = false
  description = "Determines whether to provision rotation parameters."
}

variable "rotation_lambda_arn" {
  type        = string
  default     = null
  description = "The ARN of the Lambda function that can rotate the secret."
}

variable "rotation_period_days" {
  type        = number
  default     = null
  description = "Specifies the number of days between rotations."
}

variable "rotation_duration" {
  type        = string
  default     = null
  description = "The length of the rotation window (e.g., '3h')."
}

variable "rotation_schedule_expression" {
  type        = string
  default     = null
  description = "A cron or rate expression that defines when the secret rotates (e.g., 'cron(0 1 * * ? *)')."
}
