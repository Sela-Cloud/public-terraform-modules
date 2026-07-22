variable "project_id" { type = string }
variable "cloud_nat" {
  type = map(object({
    name                                = string
    router                              = string
    region                              = string
    nat_ip_allocate_option              = optional(string, "AUTO_ONLY")
    nat_ips                             = optional(list(string), [])
    drain_nat_ips                       = optional(list(string), [])
    source_subnetwork_ip_ranges_to_nat  = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")
    subnetworks                         = optional(list(object({ name = string, source_ip_ranges_to_nat = list(string), secondary_ip_range_names = optional(list(string), []) })), [])
    min_ports_per_vm                    = optional(number)
    max_ports_per_vm                    = optional(number)
    enable_endpoint_independent_mapping = optional(bool, false)
    enable_dynamic_port_allocation      = optional(bool, false)
    auto_network_tier                   = optional(string)
    log_filter                          = optional(string, "ERRORS_ONLY")
  }))
  validation {
    condition     = alltrue([for nat in values(var.cloud_nat) : !(nat.enable_endpoint_independent_mapping && nat.enable_dynamic_port_allocation)])
    error_message = "Endpoint-independent mapping and dynamic port allocation cannot both be enabled."
  }
  validation {
    condition     = alltrue([for nat in values(var.cloud_nat) : nat.nat_ip_allocate_option != "MANUAL_ONLY" || length(nat.nat_ips) > 0])
    error_message = "MANUAL_ONLY NAT requires one or more reserved NAT IP self links."
  }
}
