variable "project_id" {
  type = string
}

variable "cloud_nat" {
  type = map(object({
    name                                = string
    router                              = string
    region                              = string
    source_subnetwork_ip_ranges_to_nat  = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")
    min_ports_per_vm                    = optional(number)
    max_ports_per_vm                    = optional(number)
    enable_endpoint_independent_mapping = optional(bool, false)
    enable_dynamic_port_allocation      = optional(bool, false)
    log_filter                          = optional(string, "ERRORS_ONLY")
  }))

  validation {
    condition     = alltrue([for nat in values(var.cloud_nat) : !(nat.enable_endpoint_independent_mapping && nat.enable_dynamic_port_allocation)])
    error_message = "Endpoint-independent mapping and dynamic port allocation cannot both be enabled."
  }

  validation {
    condition     = alltrue([for nat in values(var.cloud_nat) : nat.min_ports_per_vm == null || nat.max_ports_per_vm == null || nat.min_ports_per_vm <= nat.max_ports_per_vm])
    error_message = "Minimum ports per VM cannot exceed maximum ports per VM."
  }
}
