variable "private_endpoint" {
  description = "Map of Azure Private Endpoint configurations to create."
  type = map(object({
    name                          = optional(string, "pe-default")
    resource_group_name           = optional(string, "rg-default")
    location                      = optional(string, "eastus")
    subnet_id                     = string
    custom_network_interface_name = optional(string, null)
    private_service_connection = optional(object({
      name                              = optional(string, "psc-default")
      private_connection_resource_id    = optional(string, null)
      private_connection_resource_alias = optional(string, null)
      subresource_names                 = optional(list(string), null)
      is_manual_connection              = optional(bool, false)
      request_message                   = optional(string, null)
      }), {
      name                              = "psc-default"
      private_connection_resource_id    = null
      private_connection_resource_alias = null
      subresource_names                 = null
      is_manual_connection              = false
      request_message                   = null
    })
    private_dns_zone_group = optional(object({
      name                 = optional(string, "default")
      private_dns_zone_ids = list(string)
    }), null)
    ip_configurations = optional(list(object({
      name               = string
      private_ip_address = string
      subresource_name   = optional(string, null)
      member_name        = optional(string, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
