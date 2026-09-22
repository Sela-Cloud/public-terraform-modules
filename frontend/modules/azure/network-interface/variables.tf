variable "network_interface" {
  description = "Map of Azure Network Interface configurations to create."

  type = map(object({
    name                = string
    resource_group_name = string
    location            = string

    ip_configurations = list(object({
      name                                               = string
      subnet_id                                          = optional(string)
      private_ip_address_allocation                      = optional(string, "Dynamic")
      private_ip_address                                 = optional(string)
      private_ip_address_version                          = optional(string, "IPv4")
      public_ip_address_id                               = optional(string)
      primary                                            = optional(bool, true)
      gateway_load_balancer_frontend_ip_configuration_id = optional(string)
    }))

    dns_servers                   = optional(list(string), [])
    edge_zone                     = optional(string)
    enable_ip_forwarding          = optional(bool, false)
    enable_accelerated_networking = optional(bool, false)
    internal_dns_name_label       = optional(string)
    network_security_group_id     = optional(string)
    auxiliary_mode                = optional(string)
    auxiliary_sku                 = optional(string)
    tags                          = optional(map(string), {})
  }))

  default = {}
}
