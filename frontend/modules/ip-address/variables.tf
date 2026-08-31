variable "project_id" {
  type = string
}

variable "ip_address" {
  description = "External static IP addresses configured through the Sela Deployer catalog. Regional addresses (google_compute_address) require a region; global addresses (google_compute_global_address) do not."

  type = map(object({
    name         = string
    type         = optional(string, "REGIONAL")
    region       = optional(string)
    ip_version   = optional(string, "IPV4")
    network_tier = optional(string, "PREMIUM")
    description  = optional(string)
    labels       = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : contains(["REGIONAL", "GLOBAL"], addr.type)
    ])
    error_message = "type must be 'REGIONAL' or 'GLOBAL'."
  }

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : contains(["IPV4", "IPV6"], addr.ip_version)
    ])
    error_message = "ip_version must be 'IPV4' or 'IPV6'."
  }

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : contains(["PREMIUM", "STANDARD"], addr.network_tier)
    ])
    error_message = "network_tier must be 'PREMIUM' or 'STANDARD'."
  }

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : addr.type != "REGIONAL" || (addr.region != null && trimspace(addr.region) != "")
    ])
    error_message = "region is required when type is REGIONAL."
  }
}
