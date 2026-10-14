################################################################################
# General
################################################################################

variable "name" {
  description = "Name of the DynamoDB table, applied as the 'Name' tag."
  type        = string
  default     = "dynamodb-table-default"
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput. Valid values: 'PROVISIONED' or 'PAY_PER_REQUEST'."
  type        = string
  default     = "PROVISIONED"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be either 'PROVISIONED' or 'PAY_PER_REQUEST'."
  }
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must appear in the attribute list."
  type        = string
  default     = "id"
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key. Must appear in the attribute list, if set."
  type        = string
  default     = null
}

variable "attribute" {
  description = "Attributes used by the table's own keys or by its global/local secondary indexes. Only list attributes actually used as a key somewhere -- adding unused attributes causes an infinite plan loop."
  type = list(object({
    name = string
    type = string
  }))
  default = [{ name = "id", type = "S" }]

  validation {
    condition     = alltrue([for a in var.attribute : contains(["S", "N", "B"], a.type)])
    error_message = "Each attribute's type must be one of 'S' (string), 'N' (number), or 'B' (binary)."
  }
}

variable "read_capacity" {
  description = "Table-level read capacity units. Required when billing_mode is PROVISIONED, must be left null otherwise."
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Table-level write capacity units. Required when billing_mode is PROVISIONED, must be left null otherwise."
  type        = number
  default     = null
}

variable "table_class" {
  description = "Storage class of the table. Valid values: 'STANDARD' or 'STANDARD_INFREQUENT_ACCESS'."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class must be either 'STANDARD' or 'STANDARD_INFREQUENT_ACCESS'."
  }
}

variable "deletion_protection_enabled" {
  description = "Whether to enable deletion protection for the table."
  type        = bool
  default     = false
}

################################################################################
# Streams
################################################################################

variable "stream_enabled" {
  description = "Whether to enable DynamoDB Streams."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "What information is written to the stream. Required when stream_enabled is true. Valid values: 'KEYS_ONLY', 'NEW_IMAGE', 'OLD_IMAGE', 'NEW_AND_OLD_IMAGES'."
  type        = string
  default     = null

  validation {
    condition     = var.stream_view_type == null || contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "stream_view_type must be one of 'KEYS_ONLY', 'NEW_IMAGE', 'OLD_IMAGE', 'NEW_AND_OLD_IMAGES'."
  }
}

################################################################################
# Secondary Indexes
################################################################################

variable "global_secondary_index" {
  description = "Global Secondary Indexes. Each needs a unique key (Terraform-only, not sent to AWS). read_capacity/write_capacity are required when the table's billing_mode is PROVISIONED."
  type = list(object({
    key                = string
    name               = string
    hash_key           = string
    range_key          = optional(string, null)
    projection_type    = string
    non_key_attributes = optional(list(string), null)
    read_capacity      = optional(number, null)
    write_capacity     = optional(number, null)
  }))
  default = []

  validation {
    condition     = alltrue([for g in var.global_secondary_index : contains(["ALL", "KEYS_ONLY", "INCLUDE"], g.projection_type)])
    error_message = "Each global_secondary_index's projection_type must be one of 'ALL', 'KEYS_ONLY', 'INCLUDE'."
  }
}

variable "local_secondary_index" {
  description = "Local Secondary Indexes. Only valid when the table itself has a range_key, and can only be set at table creation. Each needs a unique key (Terraform-only, not sent to AWS)."
  type = list(object({
    key                = string
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), null)
  }))
  default = []

  validation {
    condition     = alltrue([for l in var.local_secondary_index : contains(["ALL", "KEYS_ONLY", "INCLUDE"], l.projection_type)])
    error_message = "Each local_secondary_index's projection_type must be one of 'ALL', 'KEYS_ONLY', 'INCLUDE'."
  }
}

################################################################################
# Feature Blocks
################################################################################

variable "ttl" {
  description = "Time To Live configuration. attribute_name is required when enabled is true, and must be left null otherwise."
  type = object({
    enabled        = optional(bool, false)
    attribute_name = optional(string, null)
  })
  default = {}
}

variable "point_in_time_recovery" {
  description = "Point-in-time recovery configuration."
  type = object({
    enabled                 = optional(bool, false)
    recovery_period_in_days = optional(number, null)
  })
  default = {}
}

variable "server_side_encryption" {
  description = "Server-side encryption configuration. If enabled is false, AWS uses its own owned key (shown as 'DEFAULT' in the console). If enabled is true and kms_key_arn is null, AWS uses the default AWS-managed key (shown as 'KMS'). Set kms_key_arn for a customer-managed key."
  type = object({
    enabled     = optional(bool, false)
    kms_key_arn = optional(string, null)
  })
  default = {}
}

variable "contributor_insights_enabled" {
  description = "Whether to enable CloudWatch Contributor Insights for the table."
  type        = bool
  default     = false
}

################################################################################
# Global Tables (Replicas)
################################################################################

variable "replica" {
  description = "Global Tables v2 replica regions. Each needs a unique key (Terraform-only, not sent to AWS)."
  type = list(object({
    key                         = string
    region_name                 = string
    kms_key_arn                 = optional(string, null)
    propagate_tags              = optional(bool, false)
    consistency_mode            = optional(string, "EVENTUAL")
    point_in_time_recovery      = optional(bool, false)
    deletion_protection_enabled = optional(bool, null)
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.replica : contains(["EVENTUAL", "STRONG"], r.consistency_mode)])
    error_message = "Each replica's consistency_mode must be 'EVENTUAL' or 'STRONG'."
  }
}

################################################################################
# Auto Scaling
################################################################################

variable "autoscaling" {
  description = <<-EOT
    Application Auto Scaling targets for this table, only valid when billing_mode is PROVISIONED.
    Each needs a unique key (Terraform-only, not sent to AWS). dimension is one of 'table_read',
    'table_write', 'gsi_read', 'gsi_write' -- the gsi_* dimensions require index_name to match an
    existing global_secondary_index name.
  EOT
  type = list(object({
    key          = string
    dimension    = string
    index_name   = optional(string, null)
    min_capacity = number
    max_capacity = number
    target_value = optional(number, 70)
  }))
  default = []

  validation {
    condition     = alltrue([for a in var.autoscaling : contains(["table_read", "table_write", "gsi_read", "gsi_write"], a.dimension)])
    error_message = "Each autoscaling entry's dimension must be one of 'table_read', 'table_write', 'gsi_read', 'gsi_write'."
  }
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}
