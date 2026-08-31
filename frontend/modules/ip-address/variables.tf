variable "project_id" {
  type = string
}

variable "ip_address" {
  description = "External static regional IP addresses configured through the Sela Deployer catalog."

  type = map(object({
    name         = string
    region       = string
    network_tier = optional(string, "PREMIUM")
    description  = optional(string)
    labels       = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for addr in values(var.ip_address) : contains(["PREMIUM", "STANDARD"], addr.network_tier)
    ])
    error_message = "network_tier must be 'PREMIUM' or 'STANDARD'."
  }
}
