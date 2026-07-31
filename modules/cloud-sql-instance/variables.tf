variable "project_id" { type = string }
variable "name" { type = string }
variable "region" { type = string }
variable "database_version" { type = string }
variable "edition" { type = string }
variable "tier" { type = string }
variable "availability_type" { type = string }
variable "disk_type" { type = string }
variable "disk_size" {
  type    = number
  default = null
}
variable "disk_autoresize" {
  type    = bool
  default = true
}
variable "disk_autoresize_limit" {
  type    = number
  default = 0
}
variable "ipv4_enabled" {
  type    = bool
  default = false
}
variable "private_network" {
  type    = string
  default = null
}
variable "allocated_ip_range" {
  type    = string
  default = null
}
variable "enable_private_path_for_google_cloud_services" {
  type    = bool
  default = false
}
variable "ssl_mode" {
  type    = string
  default = "ENCRYPTED_ONLY"
}
variable "authorized_networks" {
  type = map(object({
    name            = optional(string)
    value           = string
    expiration_time = optional(string)
  }))
  default = {}
}
variable "deletion_protection" {
  type    = bool
  default = true
}
variable "deletion_protection_enabled" {
  type    = bool
  default = true
}
variable "connector_enforcement" {
  type    = string
  default = null
}
variable "backup_enabled" {
  type    = bool
  default = true
}
variable "backup_start_time" {
  type    = string
  default = null
}
variable "backup_location" {
  type    = string
  default = null
}
variable "binary_log_enabled" {
  type    = bool
  default = false
}
variable "point_in_time_recovery_enabled" {
  type    = bool
  default = false
}
variable "transaction_log_retention_days" {
  type    = number
  default = null
}
variable "retained_backups" {
  type    = number
  default = 7
}
variable "maintenance_day" {
  type    = number
  default = null
}
variable "maintenance_hour" {
  type    = number
  default = null
}
variable "maintenance_update_track" {
  type    = string
  default = "stable"
}
variable "query_insights_enabled" {
  type    = bool
  default = true
}
variable "query_string_length" {
  type    = number
  default = 1024
}
variable "query_plans_per_minute" {
  type    = number
  default = 5
}
variable "record_application_tags" {
  type    = bool
  default = true
}
variable "record_client_address" {
  type    = bool
  default = false
}
variable "database_flags" {
  type = map(object({
    name  = string
    value = string
  }))
  default = {}
}
variable "password_validation_policy" {
  type = object({
    enabled                     = optional(bool, true)
    min_length                  = optional(number, 12)
    complexity                  = optional(string, "COMPLEXITY_DEFAULT")
    reuse_interval              = optional(number)
    disallow_username_substring = optional(bool, true)
    password_change_interval    = optional(string)
  })
  default = null
}
