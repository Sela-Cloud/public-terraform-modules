resource "azurerm_user_assigned_identity" "identity" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "role_assignment" {
  for_each = { for idx, ra in var.role_assignments : "${ra.scope}-${coalesce(ra.role_definition_name, ra.role_definition_id, tostring(idx))}" => ra }

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  role_definition_id   = each.value.role_definition_id
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  description          = each.value.description
}
