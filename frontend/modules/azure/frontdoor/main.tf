module "frontdoor" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/frontdoor?ref=v0.7.6"
  for_each = var.frontdoor

  name                        = each.value.name
  resource_group_name         = each.value.resource_group_name
  friendly_name               = each.value.friendly_name
  load_balancer_enabled       = each.value.load_balancer_enabled
  frontend_endpoints          = each.value.frontend_endpoints
  backend_pools               = each.value.backend_pools
  backend_pool_load_balancing = each.value.backend_pool_load_balancing
  backend_pool_health_probes  = each.value.backend_pool_health_probes
  routing_rules               = each.value.routing_rules
  tags                        = each.value.tags
}
