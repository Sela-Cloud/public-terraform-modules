variable "network_security_group" {
  description = "Map of Azure Network Security Group configurations to create."
  type = map(object({
    name                = optional(string, "nsg-default")
    resource_group_name = optional(string, "rg-default")
    location            = optional(string, "eastus")
    security_rules = optional(list(object({
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
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
