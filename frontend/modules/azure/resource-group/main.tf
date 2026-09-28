module "resource_group" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/resource-group?ref=v0.7.6"
  for_each = var.resource_group

  name       = each.value.name
  location   = each.value.location
  tags       = each.value.tags
  managed_by = each.value.managed_by
}
