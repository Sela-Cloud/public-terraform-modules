variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "sqs" {
  description = "Map of AWS SQS queue configurations to deploy, keyed by queue name."
  type = map(object({
    name                              = optional(string, null)
    name_prefix                       = optional(string, null)
    visibility_timeout_seconds        = optional(number, 30)
    message_retention_seconds         = optional(number, 345600)
    max_message_size                  = optional(number, 262144)
    delay_seconds                     = optional(number, 0)
    receive_wait_time_seconds         = optional(number, 0)
    policy                            = optional(string, null)
    redrive_policy                    = optional(string, null)
    redrive_allow_policy              = optional(string, null)
    fifo_queue                        = optional(bool, false)
    content_based_deduplication       = optional(bool, false)
    deduplication_scope               = optional(string, null)
    fifo_throughput_limit             = optional(string, null)
    kms_master_key_id                 = optional(string, null)
    kms_data_key_reuse_period_seconds = optional(number, 300)
    sqs_managed_sse_enabled           = optional(bool, true)
    tags                              = optional(map(string), {})
  }))
  default = {
    "sqs-default" = {
      name                              = null
      name_prefix                       = null
      visibility_timeout_seconds        = 30
      message_retention_seconds         = 345600
      max_message_size                  = 262144
      delay_seconds                     = 0
      receive_wait_time_seconds         = 0
      policy                            = null
      redrive_policy                    = null
      redrive_allow_policy              = null
      fifo_queue                        = false
      content_based_deduplication       = false
      deduplication_scope               = null
      fifo_throughput_limit             = null
      kms_master_key_id                 = null
      kms_data_key_reuse_period_seconds = 300
      sqs_managed_sse_enabled           = true
      tags                              = {}
    }
  }
}
