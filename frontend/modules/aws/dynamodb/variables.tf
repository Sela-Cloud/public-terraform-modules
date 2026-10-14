variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "dynamodb" {
  description = "Map of DynamoDB table configurations to deploy, keyed by name."
  type = map(object({
    name                         = optional(string, null)
    billing_mode                 = optional(string, "PROVISIONED")
    hash_key                     = optional(string, "id")
    range_key                    = optional(string, null)
    read_capacity                = optional(number, null)
    write_capacity               = optional(number, null)
    table_class                  = optional(string, "STANDARD")
    deletion_protection_enabled  = optional(bool, false)
    stream_enabled               = optional(bool, false)
    stream_view_type             = optional(string, null)
    contributor_insights_enabled = optional(bool, false)

    attribute = optional(list(object({
      name = string
      type = string
    })), [{ name = "id", type = "S" }])

    global_secondary_index = optional(list(object({
      key                = string
      name               = string
      hash_key           = string
      range_key          = optional(string, null)
      projection_type    = string
      non_key_attributes = optional(list(string), null)
      read_capacity      = optional(number, null)
      write_capacity     = optional(number, null)
    })), [])

    local_secondary_index = optional(list(object({
      key                = string
      name               = string
      range_key          = string
      projection_type    = string
      non_key_attributes = optional(list(string), null)
    })), [])

    ttl = optional(object({
      enabled        = optional(bool, false)
      attribute_name = optional(string, null)
    }), {})

    point_in_time_recovery = optional(object({
      enabled                 = optional(bool, false)
      recovery_period_in_days = optional(number, null)
    }), {})

    server_side_encryption = optional(object({
      enabled     = optional(bool, false)
      kms_key_arn = optional(string, null)
    }), {})

    replica = optional(list(object({
      key                         = string
      region_name                 = string
      kms_key_arn                 = optional(string, null)
      propagate_tags              = optional(bool, false)
      consistency_mode            = optional(string, "EVENTUAL")
      point_in_time_recovery      = optional(bool, false)
      deletion_protection_enabled = optional(bool, null)
    })), [])

    autoscaling = optional(list(object({
      key          = string
      dimension    = string
      index_name   = optional(string, null)
      min_capacity = number
      max_capacity = number
      target_value = optional(number, 70)
    })), [])

    tags = optional(map(string), {})
  }))
  default = {}
}
