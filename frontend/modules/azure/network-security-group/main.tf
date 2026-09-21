module "network_security_group" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/network-security-group?ref=v0.7.6"
  for_each = var.network_security_group

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  security_rules      = each.value.security_rules
  tags                = each.value.tags
}
