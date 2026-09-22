resource "azurerm_virtual_network_peering" "peering" {
  name                                   = var.name
  resource_group_name                    = var.resource_group_name
  virtual_network_name                   = var.virtual_network_name
  remote_virtual_network_id              = var.remote_virtual_network_id
  allow_virtual_network_access           = var.allow_virtual_network_access
  allow_forwarded_traffic                = var.allow_forwarded_traffic
  allow_gateway_transit                  = var.allow_gateway_transit
  use_remote_gateways                    = var.use_remote_gateways
  peer_complete_virtual_networks_enabled = var.peer_complete_virtual_networks_enabled
  local_subnet_names                     = var.local_subnet_names
  remote_subnet_names                    = var.remote_subnet_names
  only_ipv6_peering_enabled              = var.only_ipv6_peering_enabled
  triggers                               = length(var.triggers) > 0 ? var.triggers : null
}
