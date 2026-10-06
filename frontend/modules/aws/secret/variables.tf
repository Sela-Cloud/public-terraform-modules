variable "secrets" {
  type = map(object({
    secret_id               = string
    description             = optional(string, null)
    kms_key_id              = optional(string, null)
    recovery_window_in_days = optional(number, 30)
    tags                    = optional(map(string), {})
    custom_replication      = optional(bool, false)
    replica_regions = optional(list(object({
      region     = string
      kms_key_id = optional(string, null)
    })), [])
    set_rotation                 = optional(bool, false)
    rotation_lambda_arn          = optional(string, null)
    rotation_period_days         = optional(number, null)
    rotation_duration            = optional(string, null)
    rotation_schedule_expression = optional(string, null)
  }))
  default     = {}
  description = "Map of secrets to be created in AWS Secrets Manager."
}
