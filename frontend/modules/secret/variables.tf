variable "project_id" {
  type = string
}

variable "secret" {
  description = "Secret Manager secrets configured through the Sela Deployer catalog."

  type = map(object({
    secret_id           = string
    labels              = optional(map(string), {})
    annotations         = optional(map(string), {})
    deletion_protection = optional(bool, false)
    custom_replication  = optional(bool, false)
    kms_key_name        = optional(string)
    replica_locations   = optional(list(string), [])
    expire_time         = optional(string)
    version_destroy_ttl = optional(string)
    set_rotation        = optional(bool, false)
    rotation_period     = optional(string)
    next_rotation_time  = optional(string)
    topics              = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for s in values(var.secret) : s.custom_replication || length(s.replica_locations) == 0
    ])
    error_message = "replica_locations is only used when custom_replication is true."
  }

  validation {
    condition = alltrue([
      for s in values(var.secret) : !s.custom_replication || length(s.replica_locations) > 0
    ])
    error_message = "At least one replica location is required when custom_replication is true."
  }

  validation {
    condition = alltrue([
      for s in values(var.secret) : !s.set_rotation || (s.rotation_period != null && s.next_rotation_time != null)
    ])
    error_message = "rotation_period and next_rotation_time are required when set_rotation is true."
  }
}
