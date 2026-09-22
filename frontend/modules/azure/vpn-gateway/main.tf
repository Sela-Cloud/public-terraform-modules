module "vpn_gateway" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/vpn-gateway?ref=v0.7.6"
  for_each = var.vpn_gateway

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  virtual_hub_id      = each.value.virtual_hub_id
  scale_unit          = each.value.scale_unit
  bgp_settings        = each.value.bgp_settings
  tags                = each.value.tags
}
