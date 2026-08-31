variable "project_id" {
  type = string
}

variable "ip_address" {
  description = "Static IP addresses configured through the Sela Deployer catalog. Regional addresses (google_compute_address) require a region; global addresses (google_compute_global_address) do not. Internal addresses (address_type = INTERNAL) only apply to REGIONAL and require a network and subnetwork."

  type = map(object({
    name                 = string
    type                 = optional(string, "REGIONAL")
    region               = optional(string)
    address_type         = optional(string, "EXTERNAL")
    network              = optional(string)
    subnetwork           = optional(string)
    purpose              = optional(string, "GCE_ENDPOINT")
    assign_automatically = optional(bool, true)
    address              = optional(string)
    ip_version           = optional(string, "IPV4")
    network_tier         = optional(string, "PREMIUM")
    description          = optional(string)
    labels               = optional(map(string), {})
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

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : contains(["EXTERNAL", "INTERNAL"], addr.address_type)
    ])
    error_message = "address_type must be 'EXTERNAL' or 'INTERNAL'."
  }

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : contains(["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP"], addr.purpose)
    ])
    error_message = "purpose must be 'GCE_ENDPOINT' or 'SHARED_LOADBALANCER_VIP'."
  }

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : addr.address_type != "INTERNAL" || (addr.network != null && trimspace(addr.network) != "")
    ])
    error_message = "network is required when address_type is INTERNAL."
  }

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : addr.address_type != "INTERNAL" || (addr.subnetwork != null && trimspace(addr.subnetwork) != "")
    ])
    error_message = "subnetwork is required when address_type is INTERNAL."
  }

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : addr.assign_automatically || (addr.address != null && trimspace(addr.address) != "")
    ])
    error_message = "address is required when assign_automatically is false."
  }
}
