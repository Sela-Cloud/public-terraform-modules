variable "project_id" {
  type = string
}

variable "global_ip_address" {
  description = "Global static IP addresses configured through the Sela Deployer catalog."

  type = map(object({
    name                 = string
    ip_version           = optional(string, "IPV4")
    assign_automatically = optional(bool, true)
    address              = optional(string)
    description          = optional(string)
    labels               = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for addr in values(var.global_ip_address) : contains(["IPV4", "IPV6"], addr.ip_version)
    ])
    error_message = "ip_version must be 'IPV4' or 'IPV6'."
  }

  validation {
    condition = alltrue([
      for addr in values(var.global_ip_address) : addr.assign_automatically || (addr.address != null && trimspace(addr.address) != "")
    ])
    error_message = "address is required when assign_automatically is false."
  }
}
