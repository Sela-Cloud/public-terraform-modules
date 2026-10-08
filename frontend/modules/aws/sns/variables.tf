variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "sns" {
  description = "Map of AWS SNS topic configurations to deploy, keyed by topic name."
  type = map(object({
    name                        = optional(string, "sns-default")
    name_prefix                 = optional(string, null)
    display_name                = optional(string, null)
    kms_master_key_id           = optional(string, null)
    fifo_topic                  = optional(bool, false)
    content_based_deduplication = optional(bool, false)
    delivery_policy             = optional(string, null)
    policy                      = optional(string, null)
    subscriptions = optional(map(object({
      protocol             = string
      endpoint             = string
      raw_message_delivery = optional(bool, false)
      filter_policy        = optional(string, null)
    })), {})
    tags = optional(map(string), {})
  }))
  default = {
    "sns-default" = {
      name                        = "sns-default"
      name_prefix                 = null
      display_name                = null
      kms_master_key_id           = null
      fifo_topic                  = false
      content_based_deduplication = false
      delivery_policy             = null
      policy                      = null
      subscriptions               = {}
      tags                        = {}
    }
  }
}
