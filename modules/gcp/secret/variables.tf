variable "project_id" {
  description = "Project where the secret is created."
  type        = string
}

variable "secret_id" {
  description = "Name of the secret. Must be unique within the project."
  type        = string
}

variable "labels" {
  description = "Labels to apply to the secret."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Custom, non-identifying metadata to attach to the secret."
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "If true, Terraform is prevented from destroying this secret."
  type        = bool
  default     = false
}

variable "custom_replication" {
  description = "If true, replicate to the specific locations in replica_locations instead of letting Google manage placement automatically. Cannot be changed after the secret is created."
  type        = bool
  default     = false
}

variable "kms_key_name" {
  description = "Customer-managed encryption key for automatic replication. Only used when custom_replication is false."
  type        = string
  default     = null
}

variable "replica_locations" {
  description = "Locations to replicate to. Only used when custom_replication is true."
  type        = list(string)
  default     = []
}

variable "expire_time" {
  description = "RFC3339 UTC timestamp at which the secret is scheduled to expire."
  type        = string
  default     = null
}

variable "version_destroy_ttl" {
  description = "Delay (a duration such as '86400s') before a requested version destruction actually happens."
  type        = string
  default     = null
}

variable "set_rotation" {
  description = "If true, send rotation notifications on rotation_period/next_rotation_time. Does not automatically rotate the secret value."
  type        = bool
  default     = false
}

variable "rotation_period" {
  description = "Duration (e.g. '2592000s') between rotation notifications. Required when set_rotation is true."
  type        = string
  default     = null
}

variable "next_rotation_time" {
  description = "RFC3339 UTC timestamp of the next rotation notification. Required when set_rotation is true."
  type        = string
  default     = null
}

variable "topics" {
  description = "Pub/Sub topics (full resource names, projects/*/topics/*) to notify on secret or version changes."
  type        = list(string)
  default     = []
}
