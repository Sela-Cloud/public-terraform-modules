variable "project_id" {
  description = "The GCP project that owns the subnetworks."
  type        = string
}

variable "subnet" {
  description = "Subnetwork definitions, keyed by subnet name."
  type = map(object({
    name                           = string
    region                         = string
    network                        = string
    ip_cidr_range                  = string
    description                    = optional(string, "")
    purpose                        = optional(string, "PRIVATE")
    role                           = optional(string)
    private_ip_google_access       = optional(bool, false)
    private_ipv6_google_access     = optional(string)
    stack_type                     = optional(string, "IPV4_ONLY")
    ipv6_access_type               = optional(string)
    reserved_internal_range        = optional(string)
    flow_logs                      = optional(bool, false)
    flow_logs_aggregation_interval = optional(string, "INTERVAL_5_SEC")
    flow_logs_sampling             = optional(number, 0.5)
    flow_logs_metadata             = optional(string, "INCLUDE_ALL_METADATA")
    flow_logs_metadata_fields      = optional(list(string), [])
    flow_logs_filter_expr          = optional(string, "true")
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = optional(string)
    })), [])
  }))

  validation {
    condition     = alltrue([for item in values(var.subnet) : contains(["IPV4_ONLY", "IPV4_IPV6", "IPV6_ONLY"], item.stack_type)])
    error_message = "stack_type must be IPV4_ONLY, IPV4_IPV6, or IPV6_ONLY."
  }
}
