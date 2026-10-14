resource "azurerm_policy_definition" "policy" {
  name                = var.name
  display_name        = var.display_name
  policy_type         = var.policy_type
  mode                = var.mode
  description         = var.description
  management_group_id = var.management_group_id
  policy_rule         = var.policy_rule
  metadata            = var.metadata
  parameters          = var.parameters

  timeouts {
    create = "60m"
    update = "60m"
    read   = "5m"
    delete = "60m"
  }
}
