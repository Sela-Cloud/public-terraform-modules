variable "project_id" {
  type = string
}

variable "service_connection_policy" {
  description = "Service Connection Policies configured through the Sela Deployer catalog."

  type = map(object({
    name                 = string
    location             = string
    network              = string
    description          = optional(string)
    labels               = optional(map(string), {})
    service_class        = optional(string, "gcp-memorystore-redis")
    subnetworks          = list(string)
    psc_connection_limit = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for p in values(var.service_connection_policy) : length(p.subnetworks) > 0
    ])
    error_message = "At least one subnetwork is required."
  }

  validation {
    condition = length(distinct([
      for p in values(var.service_connection_policy) : "${p.network}|${p.location}|${p.service_class}"
    ])) == length(values(var.service_connection_policy))
    error_message = "Create only one Service Connection Policy per network, location, and service_class combination. Add or manage further subnetworks through that existing shared policy."
  }
}
