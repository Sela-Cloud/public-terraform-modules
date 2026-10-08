variable "name" {
  description = "The name of the SNS topic. For FIFO topics, the name must end with '.fifo'."
  type        = string
  default     = "sns-default"
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name."
  type        = string
  default     = null
}

variable "display_name" {
  description = "The display name for the SNS topic."
  type        = string
  default     = null
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed CMK for Amazon SNS or a custom KMS Key (e.g. 'alias/aws/sns')."
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Boolean indicating whether or not to create a FIFO (first-in-first-out) topic."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO topics."
  type        = bool
  default     = false
}

variable "delivery_policy" {
  description = "The SNS delivery policy as a JSON string."
  type        = string
  default     = null
}

variable "policy" {
  description = "The fully-formed IAM Policy document as a JSON string to apply to the SNS topic."
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "SNS topic subscriptions to create. 'name' is a Terraform-only identifier for each subscription (not sent to AWS) -- it just needs to be unique within this topic's list."
  type = list(object({
    name                 = string
    protocol             = string
    endpoint             = string
    raw_message_delivery = optional(bool, false)
    filter_policy        = optional(string, null)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
