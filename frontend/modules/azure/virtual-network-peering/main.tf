module "virtual_network_peering" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/virtual-network-peering?ref=v0.7.6"
  for_each = var.virtual_network_peering

  name                                   = each.value.name
  resource_group_name                    = each.value.resource_group_name
  virtual_network_name                   = each.value.virtual_network_name
  remote_virtual_network_id              = each.value.remote_virtual_network_id
  allow_virtual_network_access           = each.value.allow_virtual_network_access
  allow_forwarded_traffic                = each.value.allow_forwarded_traffic
  allow_gateway_transit                  = each.value.allow_gateway_transit
  use_remote_gateways                    = each.value.use_remote_gateways
  peer_complete_virtual_networks_enabled = each.value.peer_complete_virtual_networks_enabled
  local_subnet_names                     = each.value.local_subnet_names
  remote_subnet_names                    = each.value.remote_subnet_names
  only_ipv6_peering_enabled              = each.value.only_ipv6_peering_enabled
  triggers                               = each.value.triggers
}
