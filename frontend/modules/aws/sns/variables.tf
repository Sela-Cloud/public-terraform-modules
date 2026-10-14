variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "sns" {
  description = "Map of AWS SNS topic configurations to deploy, keyed by topic name."
  type = map(object({
    name                        = optional(string, null)
    name_prefix                 = optional(string, null)
    display_name                = optional(string, null)
    kms_master_key_id           = optional(string, null)
    fifo_topic                  = optional(bool, false)
    content_based_deduplication = optional(bool, false)
    delivery_policy             = optional(string, null)
    policy                      = optional(string, null)
    subscriptions = optional(list(object({
      name                 = string
      protocol             = string
      endpoint             = string
      raw_message_delivery = optional(bool, false)
      filter_policy        = optional(string, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
