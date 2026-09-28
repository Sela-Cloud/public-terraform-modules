variable "virtual_network_peering" {
  description = "Map of Azure Virtual Network Peering configurations to create."
  type = map(object({
    name                                   = optional(string, "peer-default")
    resource_group_name                    = optional(string, "rg-default")
    virtual_network_name                   = optional(string, "vnet-default")
    remote_virtual_network_id              = string
    allow_virtual_network_access           = optional(bool, true)
    allow_forwarded_traffic                = optional(bool, false)
    allow_gateway_transit                  = optional(bool, false)
    use_remote_gateways                    = optional(bool, false)
    peer_complete_virtual_networks_enabled = optional(bool, true)
    local_subnet_names                     = optional(list(string), null)
    remote_subnet_names                    = optional(list(string), null)
    only_ipv6_peering_enabled              = optional(bool, false)
    triggers                               = optional(map(string), {})
  }))
  default = {}
}
