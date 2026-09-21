variable "name" {
  description = "Subnet name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name."
  type        = string
}

variable "virtual_network_name" {
  description = "Virtual Network name."
  type        = string
}

variable "address_prefixes" {
  description = "Subnet CIDR ranges."
  type        = list(string)
}

variable "service_endpoints" {
  description = "List of Service Endpoints."
  type        = list(string)
  default     = []
}

variable "service_endpoint_policy_ids" {
  description = "Service Endpoint Policy IDs."
  type        = list(string)
  default     = []
}

variable "private_endpoint_network_policies" {
  description = "Private Endpoint Network Policies."
  type        = string
  default     = "Disabled"
}

variable "private_link_service_network_policies_enabled" {
  description = "Private Link Service Network Policies."
  type        = bool
  default     = false
}

variable "delegation" {
  description = "Subnet delegation."
  type = object({
    name = string

    service_delegation = object({
      name    = string
      actions = optional(list(string), [])
    })
  })

  default = null
}