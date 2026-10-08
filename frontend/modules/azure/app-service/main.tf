module "app_service" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/app-service?ref=v0.9.3"
  for_each = var.app_service

  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  os_type                       = each.value.os_type
  create_service_plan           = each.value.create_service_plan
  service_plan_name             = each.value.service_plan_name
  service_plan_sku              = each.value.service_plan_sku
  service_plan_id               = each.value.service_plan_id
  zone_balancing_enabled        = each.value.zone_balancing_enabled
  https_only                    = each.value.https_only
  client_affinity_enabled       = each.value.client_affinity_enabled
  client_certificate_enabled    = each.value.client_certificate_enabled
  client_certificate_mode       = each.value.client_certificate_mode
  public_network_access_enabled = each.value.public_network_access_enabled
  virtual_network_subnet_id     = each.value.virtual_network_subnet_id
  identity_type                 = each.value.identity_type
  identity_ids                  = each.value.identity_ids
  app_settings                  = each.value.app_settings
  site_config                   = each.value.site_config
  connection_strings            = each.value.connection_strings
  storage_mounts                = each.value.storage_mounts
  tags                          = each.value.tags
}
