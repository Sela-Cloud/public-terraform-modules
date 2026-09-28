resource "azurerm_role_assignment" "role_assignment" {
  name                                   = var.name != null && can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.name)) ? var.name : null
  scope                                  = var.scope
  role_definition_name                   = var.role_definition_id == null ? var.role_definition_name : null
  role_definition_id                     = var.role_definition_id
  principal_id                           = var.principal_id
  principal_type                         = var.principal_type
  description                            = var.description
  skip_service_principal_aad_check       = var.skip_service_principal_aad_check
  condition                              = var.condition
  condition_version                      = var.condition != null && var.condition_version != null ? var.condition_version : null
  delegated_managed_identity_resource_id = var.delegated_managed_identity_resource_id
}
