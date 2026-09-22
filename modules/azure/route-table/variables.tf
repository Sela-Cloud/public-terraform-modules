variable "name" {
  description = "The name of the Route Table. Changing this forces a new resource to be created."
  type        = string
  default     = "rt-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Route Table name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Route Table. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "The Azure Region where the Route Table should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "bgp_route_propagation_enabled" {
  description = "Boolean flag which controls propagation of routes learned by BGP on that route table. True means enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "routes" {
  description = "List of route objects representing inline routes to be created with the Route Table."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for route in var.routes : (
        contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], route.next_hop_type) &&
        (route.next_hop_type != "VirtualAppliance" || (route.next_hop_in_ip_address != null && length(route.next_hop_in_ip_address) > 0))
      )
    ])
    error_message = "Each route must have a valid next_hop_type (VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, None), and next_hop_in_ip_address must be provided when next_hop_type is VirtualAppliance."
  }
}

variable "subnet_ids" {
  description = "Optional list of Subnet IDs to associate with this Route Table. If empty, no subnet associations are created."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Route Table."
  type        = map(string)
  default     = {}
}
