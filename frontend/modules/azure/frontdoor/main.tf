module "frontdoor" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/frontdoor?ref=azure-frontdoor-standard-premium"
  for_each = var.frontdoor

  name                     = each.value.name
  resource_group_name      = each.value.resource_group_name
  sku_name                 = each.value.sku_name
  response_timeout_seconds = each.value.response_timeout_seconds
  endpoints                = each.value.endpoints
  origin_groups            = each.value.origin_groups
  routes                   = each.value.routes
  tags                     = each.value.tags
}
