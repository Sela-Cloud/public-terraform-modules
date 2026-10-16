module "vpn_gateway" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/vpn-gateway?ref=v0.9.15"
  for_each = var.vpn_gateway

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  virtual_hub         = each.value.virtual_hub
  virtual_wan         = each.value.virtual_wan
  scale_unit          = each.value.scale_unit
  bgp_settings        = each.value.bgp_settings
  tags                = each.value.tags
}
