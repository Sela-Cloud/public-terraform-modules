variable "load_balancer" {
  description = "Map of Azure Load Balancer configurations to create."

  type = map(object({
    # Mandatory attributes (No default values)
    name                = string
    resource_group_name = string
    location            = string

    frontend_ip_configurations = list(object({
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

    # Optional Sizing & Placement attributes (With default values)
    sku       = optional(string, "Standard")
    sku_tier  = optional(string, "Regional")
    type      = optional(string, "Public")
    edge_zone = optional(string)
    tags      = optional(map(string), {})

    # Optional Sub-Resource Blocks (With default values)
    backend_pools = optional(list(object({
      name               = string
      virtual_network_id = optional(string)
    })), [])

    health_probes = optional(list(object({
      name                = string
      port                = number
      protocol            = optional(string, "Tcp")
      request_path        = optional(string)
      interval_in_seconds = optional(number, 15)
      number_of_probes    = optional(number, 2)
      probe_threshold     = optional(number)
    })), [])

    load_balancing_rules = optional(list(object({
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
    })), [])

    inbound_nat_rules = optional(list(object({
      name                           = string
      frontend_ip_configuration_name = string
      frontend_port                  = number
      backend_port                   = number
      protocol                       = optional(string, "Tcp")
      idle_timeout_in_minutes        = optional(number, 4)
      enable_floating_ip             = optional(bool, false)
    })), [])
  }))

  default = {}
}
