module "local_network_gateway" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/local-network-gateway?ref=v0.7.6"
  for_each = var.local_network_gateway

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  gateway_address     = each.value.gateway_address
  gateway_fqdn        = each.value.gateway_fqdn
  address_space       = each.value.address_space
  bgp_settings        = each.value.bgp_settings
  tags                = each.value.tags
}
