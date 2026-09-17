module "virtual_network" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/virtual-network?ref=v0.7.6"
  for_each = var.virtual_network

  name                           = each.value.name
  resource_group_name            = each.value.resource_group_name
  location                       = each.value.location
  address_space                  = each.value.address_space
  dns_servers                    = each.value.dns_servers
  bgp_community                  = each.value.bgp_community
  flow_timeout_in_minutes        = each.value.flow_timeout_in_minutes
  edge_zone                      = each.value.edge_zone
  private_endpoint_vnet_policies = each.value.private_endpoint_vnet_policies
  ddos_protection_plan           = each.value.ddos_protection_plan
  encryption                     = each.value.encryption
  tags                           = each.value.tags
}
