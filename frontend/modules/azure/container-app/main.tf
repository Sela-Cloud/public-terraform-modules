module "container_app" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/container-app?ref=v0.7.6"
  for_each = var.container_app

  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  container_app_environment_id = each.value.container_app_environment_id
  revision_mode                = each.value.revision_mode
  workload_profile_name        = each.value.workload_profile_name
  template                     = each.value.template
  ingress                      = each.value.ingress
  identity                     = each.value.identity
  secrets                      = each.value.secrets
  registries                   = each.value.registries
  dapr                         = each.value.dapr
  tags                         = each.value.tags
}
