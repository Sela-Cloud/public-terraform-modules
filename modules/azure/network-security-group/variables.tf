variable "name" {
  description = "The name of the Network Security Group. Changing this forces a new resource to be created."
  type        = string
  default     = "nsg-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Network Security Group name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Network Security Group. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "The Azure Region where the Network Security Group should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "security_rules" {
  description = "List of security rules representing inline rules to be created with the Network Security Group."
  type = list(object({
    name                                       = string
    description                                = optional(string, null)
    protocol                                   = optional(string, "*")
    source_port_range                          = optional(string, "*")
    source_port_ranges                         = optional(list(string), null)
    destination_port_range                     = optional(string, "*")
    destination_port_ranges                    = optional(list(string), null)
    source_address_prefix                      = optional(string, "*")
    source_address_prefixes                    = optional(list(string), null)
    source_application_security_group_ids      = optional(list(string), null)
    destination_address_prefix                 = optional(string, "*")
    destination_address_prefixes               = optional(list(string), null)
    destination_application_security_group_ids = optional(list(string), null)
    access                                     = optional(string, "Allow")
    priority                                   = optional(number, 100)
    direction                                  = optional(string, "Inbound")
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.security_rules : (
        contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], rule.protocol) &&
        contains(["Allow", "Deny"], rule.access) &&
        contains(["Inbound", "Outbound"], rule.direction) &&
        rule.priority >= 100 && rule.priority <= 4096
      )
    ])
    error_message = "Each security rule must have a valid protocol (Tcp, Udp, Icmp, Esp, Ah, *), access (Allow, Deny), direction (Inbound, Outbound), and priority between 100 and 4096."
  }
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Network Security Group."
  type        = map(string)
  default     = {}
}
