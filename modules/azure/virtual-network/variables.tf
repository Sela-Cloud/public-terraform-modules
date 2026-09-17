variable "name" {
  description = "The name of the Virtual Network. Changing this forces a new resource to be created."
  type        = string
  default     = "vnet-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 2 && length(var.name) <= 64
    error_message = "Virtual Network name must be between 2 and 64 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Virtual Network. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "The Azure Region where the Virtual Network should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "address_space" {
  description = "The address space that is used by the Virtual Network. You can supply more than one address space."
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.address_space) > 0 && can([for cidr in var.address_space : cidrhost(cidr, 0)])
    error_message = "address_space must contain at least one valid CIDR block (e.g. '10.0.0.0/16')."
  }
}

variable "dns_servers" {
  description = "List of IP addresses of DNS servers. If not specified, Azure default DNS will be used."
  type        = list(string)
  default     = []
}

variable "bgp_community" {
  description = "The BGP community attribute in format <as-number>:<community-value>."
  type        = string
  default     = null
}

variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes."
  type        = number
  default     = null

  validation {
    condition     = var.flow_timeout_in_minutes == null || can(var.flow_timeout_in_minutes >= 4 && var.flow_timeout_in_minutes <= 30)
    error_message = "flow_timeout_in_minutes must be between 4 and 30 minutes."
  }
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. Changing this forces a new Virtual Network to be created."
  type        = string
  default     = null
}

variable "private_endpoint_vnet_policies" {
  description = "The Private Endpoint VNet Policies for the Virtual Network. Possible values are 'Disabled' and 'Basic'."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "Basic"], var.private_endpoint_vnet_policies)
    error_message = "private_endpoint_vnet_policies must be either 'Disabled' or 'Basic'."
  }
}

variable "ddos_protection_plan" {
  description = "DDoS Protection Plan configuration for the Virtual Network."
  type = object({
    id     = string
    enable = optional(bool, true)
  })
  default = null
}

variable "encryption" {
  description = "Virtual Network encryption configuration."
  type = object({
    enforcement = optional(string, "AllowUnencrypted")
  })
  default = null

  validation {
    condition     = var.encryption == null || contains(["AllowUnencrypted", "DropUnencrypted"], coalesce(try(var.encryption.enforcement, null), "AllowUnencrypted"))
    error_message = "encryption enforcement must be either 'AllowUnencrypted' or 'DropUnencrypted'."
  }
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Virtual Network."
  type        = map(string)
  default     = {}
}
