variable "name" {
  description = "The name of the Public IP. Changing this forces a new resource to be created."
  type        = string
  default     = "pip-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9_])?$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Public IP name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the Public IP. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "The Azure Region where the Public IP should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are 'Static' or 'Dynamic'."
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "allocation_method must be either 'Static' or 'Dynamic'."
  }
}

variable "sku" {
  description = "The SKU of the Public IP. Accepted values are 'Basic' and 'Standard'."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "sku must be either 'Basic' or 'Standard'."
  }
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for the Public IP. Possible values are 'Regional' and 'Global'."
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "sku_tier must be either 'Regional' or 'Global'."
  }
}

variable "ip_version" {
  description = "The IP Version to use, IPv6 or IPv4. Possible values are 'IPv4' or 'IPv6'."
  type        = string
  default     = "IPv4"

  validation {
    condition     = contains(["IPv4", "IPv6"], var.ip_version)
    error_message = "ip_version must be either 'IPv4' or 'IPv6'."
  }
}

variable "idle_timeout_in_minutes" {
  description = "Specifies the timeout for the TCP idle connection. The value can be set between 4 and 30 minutes."
  type        = number
  default     = 4

  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 30
    error_message = "idle_timeout_in_minutes must be between 4 and 30 minutes."
  }
}

variable "domain_name_label" {
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the resource in the Microsoft Azure DNS system."
  type        = string
  default     = null
}

variable "reverse_fqdn" {
  description = "A fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN."
  type        = string
  default     = null
}

variable "zones" {
  description = "A collection containing the availability zone(s) to allocate the Public IP in. Availability Zones are only supported with a Standard SKU."
  type        = list(string)
  default     = []
}

variable "ddos_protection_mode" {
  description = "The DDoS protection mode of the public IP. Possible values are 'Disabled', 'Enabled', and 'VirtualNetworkInherited'."
  type        = string
  default     = "VirtualNetworkInherited"

  validation {
    condition     = contains(["Disabled", "Enabled", "VirtualNetworkInherited"], var.ddos_protection_mode)
    error_message = "ddos_protection_mode must be one of 'Disabled', 'Enabled', or 'VirtualNetworkInherited'."
  }
}

variable "ddos_protection_plan_id" {
  description = "The ID of DDoS protection plan associated with the public IP. Can only be set when ddos_protection_mode is 'Enabled'."
  type        = string
  default     = null
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Public IP should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "public_ip_prefix_id" {
  description = "If specified then public IP address allocated will be in the provided public IP prefix."
  type        = string
  default     = null
}

variable "ip_tags" {
  description = "A mapping of IP tags to assign to the public IP."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Public IP."
  type        = map(string)
  default     = {}
}
