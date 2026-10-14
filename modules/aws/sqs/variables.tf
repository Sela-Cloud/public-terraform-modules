variable "name" {
  description = "The name of the SQS queue. For FIFO queues, the name must end with '.fifo'."
  type        = string
  default     = "sqs-default"
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name."
  type        = string
  default     = null
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue in seconds (0 to 43200)."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message (60 to 1209600)."
  type        = number
  default     = 345600
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain (1024 to 262144)."
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "The time in seconds that delivery of messages in the queue will be delayed (0 to 900)."
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (0 to 20)."
  type        = number
  default     = 0
}

variable "policy" {
  description = "The JSON policy for the SQS queue."
  type        = string
  default     = null
}

variable "redrive_policy" {
  description = "The JSON policy to set up the Dead Letter Queue."
  type        = string
  default     = null
}

variable "redrive_allow_policy" {
  description = "The JSON policy to set up Dead Letter Queue redrive permissions."
  type        = string
  default     = null
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue. If true, name must end with '.fifo'."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues."
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "Specifies whether message deduplication occurs at 'messageGroup' or 'queue' level."
  type        = string
  default     = null
}

variable "fifo_throughput_limit" {
  description = "Specifies whether FIFO queue throughput applies 'perQueue' or 'perMessageGroupId'."
  type        = string
  default     = null
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed CMK or custom CMK (e.g. 'alias/aws/sqs')."
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time for which Amazon SQS can reuse a data key (60 to 86400)."
  type        = number
  default     = 300
}

variable "sqs_managed_sse_enabled" {
  description = "Boolean to enable server-side encryption (SSE-SQS)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
