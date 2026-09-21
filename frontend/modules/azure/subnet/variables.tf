variable "subnet" {
  description = "Map of Azure Subnet configurations."

  type = map(object({

    name                 = string
    resource_group_name  = string
    virtual_network_name = string

    address_prefixes = list(string)

    service_endpoints = optional(list(string), [])

    service_endpoint_policy_ids = optional(list(string), [])

    private_endpoint_network_policies = optional(
      string,
      "Disabled"
    )

    private_link_service_network_policies_enabled = optional(
      bool,
      false
    )

    delegation = optional(object({
      name = string

      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }))

  }))

  default = {}
}