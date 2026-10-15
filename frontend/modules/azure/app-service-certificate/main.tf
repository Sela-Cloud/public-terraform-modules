module "app_service_certificate" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/app-service-certificate?ref=v0.9.12"
  for_each = var.app_service_certificate

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  key_vault_secret_id = each.value.key_vault_secret_id
  key_vault_id        = each.value.key_vault_id
  pfx_blob            = each.value.pfx_blob
  password            = each.value.password
  app_service_plan_id = each.value.app_service_plan_id
  tags                = each.value.tags
}
