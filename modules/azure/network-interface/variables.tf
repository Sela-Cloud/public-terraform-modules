variable "name" {
  description = "The name of the Network Interface. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Network Interface name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the Network Interface. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Network Interface should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "ip_configurations" {
  description = "One or more IP configuration blocks for this Network Interface."
  type = list(object({
    name                                               = string
    subnet_id                                          = optional(string, null)
    private_ip_address_allocation                      = optional(string, "Dynamic")
    private_ip_address                                 = optional(string, null)
    private_ip_address_version                          = optional(string, "IPv4")
    public_ip_address_id                               = optional(string, null)
    primary                                            = optional(bool, true)
    gateway_load_balancer_frontend_ip_configuration_id = optional(string, null)
  }))

  validation {
    condition = length(var.ip_configurations) > 0 && alltrue([
      for ip in var.ip_configurations : (
        contains(["Dynamic", "Static"], coalesce(ip.private_ip_address_allocation, "Dynamic")) &&
        contains(["IPv4", "IPv6"], coalesce(ip.private_ip_address_version, "IPv4")) &&
        (coalesce(ip.private_ip_address_allocation, "Dynamic") != "Static" || (ip.private_ip_address != null && length(ip.private_ip_address) > 0))
      )
    ])
    error_message = "Each ip_configuration must have private_ip_address_allocation as 'Dynamic' or 'Static'. If 'Static', private_ip_address must be provided."
  }
}

variable "dns_servers" {
  description = "A list of IP addresses of DNS servers to assign to this Network Interface."
  type        = list(string)
  default     = []
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Network Interface should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "enable_ip_forwarding" {
  description = "Should IP Forwarding be enabled on this Network Interface? Defaults to false."
  type        = bool
  default     = false
}

variable "enable_accelerated_networking" {
  description = "Should Accelerated Networking be enabled on this Network Interface? Defaults to false."
  type        = bool
  default     = false
}

variable "internal_dns_name_label" {
  description = "The relative DNS name for this Network Interface used for internal communications between VMs in the same Virtual Network."
  type        = string
  default     = null
}

variable "network_security_group_id" {
  description = "The ID of the Network Security Group to associate with this Network Interface."
  type        = string
  default     = null
}

variable "auxiliary_mode" {
  description = "Specifies the auxiliary mode used to enable network features on the NIC. Possible values are 'AcceleratedConnections', 'Floating', or 'None'."
  type        = string
  default     = null

  validation {
    condition     = var.auxiliary_mode == null || contains(["AcceleratedConnections", "Floating", "None"], coalesce(var.auxiliary_mode, "None"))
    error_message = "auxiliary_mode must be one of 'AcceleratedConnections', 'Floating', or 'None'."
  }
}

variable "auxiliary_sku" {
  description = "Specifies the auxiliary sku used to enable network features on the NIC. Possible values are 'A8', 'A4', or 'None'."
  type        = string
  default     = null

  validation {
    condition     = var.auxiliary_sku == null || contains(["A8", "A4", "None"], coalesce(var.auxiliary_sku, "None"))
    error_message = "auxiliary_sku must be one of 'A8', 'A4', or 'None'."
  }
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Network Interface."
  type        = map(string)
  default     = {}
}
