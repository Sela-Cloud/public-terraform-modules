module "app_service_managed_certificate" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/app-service-managed-certificate?ref=azure-app-service-managed-certificate"
  for_each = var.app_service_managed_certificate

  name                       = each.value.name
  custom_hostname_binding_id = each.value.custom_hostname_binding_id
  tags                       = each.value.tags
  timeouts                   = each.value.timeouts
}
