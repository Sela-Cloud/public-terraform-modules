################################################################################
# Mandatory Variables (No Default Values)
################################################################################

variable "name" {
  description = "The name of the Azure Load Balancer."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The Load Balancer name must be 1-80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the Load Balancer."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Load Balancer should exist."
  type        = string
}

variable "frontend_ip_configurations" {
  description = "List of frontend IP configurations for the Load Balancer. At least one configuration is required."
  type = list(object({
    name                                               = string
    public_ip_address_id                               = optional(string)
    public_ip_prefix_id                                = optional(string)
    subnet_id                                          = optional(string)
    private_ip_address                                 = optional(string)
    private_ip_address_allocation                      = optional(string, "Dynamic")
    private_ip_address_version                         = optional(string, "IPv4")
    zones                                              = optional(list(string))
    gateway_load_balancer_frontend_ip_configuration_id = optional(string)
  }))

  validation {
    condition     = length(var.frontend_ip_configurations) >= 1
    error_message = "At least one frontend_ip_configuration must be specified."
  }

  validation {
    condition = alltrue([
      for f in var.frontend_ip_configurations :
      (f.public_ip_address_id != null || f.public_ip_prefix_id != null || f.subnet_id != null)
    ])
    error_message = "Each frontend IP configuration must specify either a public IP (public_ip_address_id / public_ip_prefix_id) or a subnet_id."
  }
}

################################################################################
# Optional Sizing & Placement Variables (With Default Values)
################################################################################

variable "sku" {
  description = "The SKU of the Azure Load Balancer. Accepted values are 'Basic', 'Standard', and 'Gateway'."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Gateway"], var.sku)
    error_message = "The sku must be one of: Basic, Standard, Gateway."
  }
}

variable "sku_tier" {
  description = "The SKU tier of this Load Balancer. Possible values are 'Regional' and 'Global'. Global is only supported for Standard SKU."
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "The sku_tier must be either 'Regional' or 'Global'."
  }
}

variable "type" {
  description = "Classification of the Load Balancer: 'Public' (Internet-facing) or 'Internal' (Private VNet)."
  type        = string
  default     = "Public"

  validation {
    condition     = contains(["Public", "Internal"], var.type)
    error_message = "The type must be either 'Public' or 'Internal'."
  }
}

variable "edge_zone" {
  description = "The Edge Zone within the Azure Region where this Load Balancer should exist."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the Load Balancer."
  type        = map(string)
  default     = {}
}

################################################################################
# Optional Sub-Resource Blocks (With Default Values)
################################################################################

variable "backend_pools" {
  description = "List of backend address pools to create for the Load Balancer."
  type = list(object({
    name               = string
    virtual_network_id = optional(string)
  }))
  default = []
}

variable "health_probes" {
  description = "List of health probes to create for the Load Balancer."
  type = list(object({
    name                = string
    port                = number
    protocol            = optional(string, "Tcp")
    request_path        = optional(string)
    interval_in_seconds = optional(number, 15)
    number_of_probes    = optional(number, 2)
    probe_threshold     = optional(number)
  }))
  default = []
}

variable "load_balancing_rules" {
  description = "List of load balancing rules to create for the Load Balancer."
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port                  = number
    backend_port                   = number
    protocol                       = optional(string, "Tcp")
    backend_address_pool_name      = optional(string)
    backend_address_pool_ids       = optional(list(string), [])
    probe_name                     = optional(string)
    probe_id                       = optional(string)
    enable_floating_ip             = optional(bool, false)
    idle_timeout_in_minutes        = optional(number, 4)
    load_distribution              = optional(string, "Default")
    disable_outbound_snat          = optional(bool, false)
  }))
  default = []
}

variable "inbound_nat_rules" {
  description = "List of inbound NAT rules to create for the Load Balancer."
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port                  = number
    backend_port                   = number
    protocol                       = optional(string, "Tcp")
    idle_timeout_in_minutes        = optional(number, 4)
    enable_floating_ip             = optional(bool, false)
  }))
  default = []
}
