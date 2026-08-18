variable "project_id" {
  type = string
}

variable "subnet" {
  type = map(object({
    name                           = string
    region                         = string
    network                        = string
    ip_cidr_range                  = string
    description                    = optional(string, "")
    purpose                        = optional(string, "PRIVATE")
    role                           = optional(string)
    private_ip_google_access       = optional(bool, false)
    stack_type                     = optional(string, "IPV4_ONLY")
    ipv6_access_type               = optional(string)
    reserved_internal_range        = optional(string)
    flow_logs                      = optional(bool, false)
    flow_logs_aggregation_interval = optional(string, "INTERVAL_5_SEC")
    flow_logs_sampling             = optional(number, 0.5)
    flow_logs_metadata             = optional(string, "INCLUDE_ALL_METADATA")
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = optional(string)
    })), [])
  }))
}
