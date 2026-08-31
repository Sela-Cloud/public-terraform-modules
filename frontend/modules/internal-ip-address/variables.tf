variable "project_id" {
  type = string
}

variable "internal_ip_address" {
  description = "Internal static regional IP addresses configured through the Sela Deployer catalog."

  type = map(object({
    name                 = string
    region               = string
    network              = string
    subnetwork           = string
    purpose              = optional(string, "GCE_ENDPOINT")
    assign_automatically = optional(bool, true)
    address              = optional(string)
    description          = optional(string)
    labels               = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for addr in values(var.internal_ip_address) : contains(["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP"], addr.purpose)
    ])
    error_message = "purpose must be 'GCE_ENDPOINT' or 'SHARED_LOADBALANCER_VIP'."
  }

  validation {
    condition = alltrue([
      for addr in values(var.internal_ip_address) : addr.assign_automatically || (addr.address != null && trimspace(addr.address) != "")
    ])
    error_message = "address is required when assign_automatically is false."
  }
}
