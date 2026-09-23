module "role_assignment" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/role-assignment?ref=v0.7.6"
  for_each = var.role_assignment

  name                                   = each.value.name
  scope                                  = each.value.scope
  role_definition_name                   = each.value.role_definition_name
  role_definition_id                     = each.value.role_definition_id
  principal_id                           = each.value.principal_id
  principal_type                         = each.value.principal_type
  description                            = each.value.description
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
}
