module "manage_identities" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/manage-identities?ref=v0.7.6"
  for_each = var.manage_identities

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  tags                = each.value.tags
  role_assignments    = each.value.role_assignments
}
