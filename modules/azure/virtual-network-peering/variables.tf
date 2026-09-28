variable "name" {
  description = "The name of the Virtual Network Peering. Changing this forces a new resource to be created."
  type        = string
  default     = "peer-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Virtual Network Peering name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which the Virtual Network Peering should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "virtual_network_name" {
  description = "The name of the local Virtual Network. Changing this forces a new resource to be created."
  type        = string
  default     = "vnet-default"
}

variable "remote_virtual_network_id" {
  description = "The full Azure resource ID of the remote Virtual Network to be peered. Changing this forces a new resource to be created."
  type        = string
}

variable "allow_virtual_network_access" {
  description = "Controls whether the VMs in the local virtual network can access VMs in the remote virtual network. Defaults to true."
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Controls whether forwarded traffic from the VMs in the remote virtual network will be allowed. Defaults to false."
  type        = bool
  default     = false
}

variable "allow_gateway_transit" {
  description = "Controls whether gateway links can be used in the remote virtual network's link to the local virtual network. Defaults to false."
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Controls if remote gateways can be used on the local virtual network. Defaults to false. Cannot be set to true if allow_gateway_transit is true."
  type        = bool
  default     = false

  validation {
    condition     = !(var.allow_gateway_transit && var.use_remote_gateways)
    error_message = "allow_gateway_transit and use_remote_gateways cannot both be set to true on the same peering direction."
  }
}

variable "peer_complete_virtual_networks_enabled" {
  description = "Specifies whether the complete Virtual Network address space is peered. Defaults to true. Changing this forces a new resource to be created."
  type        = bool
  default     = true
}

variable "local_subnet_names" {
  description = "A list of local Subnet names that are Subnet peered with the remote Virtual Network. Requires peer_complete_virtual_networks_enabled to be false."
  type        = list(string)
  default     = null
}

variable "remote_subnet_names" {
  description = "A list of remote Subnet names from the remote Virtual Network that are Subnet peered. Requires peer_complete_virtual_networks_enabled to be false."
  type        = list(string)
  default     = null
}

variable "only_ipv6_peering_enabled" {
  description = "Specifies whether only IPv6 address space is peered for Subnet peering. Changing this forces a new resource to be created. Defaults to false."
  type        = bool
  default     = false
}

variable "triggers" {
  description = "A mapping of key-value pairs that forces recreation of the peering when external dependencies change (e.g. remote address space)."
  type        = map(string)
  default     = {}
}
