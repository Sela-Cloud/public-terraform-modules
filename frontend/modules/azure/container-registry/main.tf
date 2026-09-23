module "container_registry" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/container-registry?ref=v0.7.6"
  for_each = var.container_registry

  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  sku                           = each.value.sku
  admin_enabled                 = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled
  network_rule_bypass_option    = each.value.network_rule_bypass_option
  zone_redundancy_enabled       = each.value.zone_redundancy_enabled
  anonymous_pull_enabled        = each.value.anonymous_pull_enabled
  data_endpoint_enabled         = each.value.data_endpoint_enabled
  export_policy_enabled         = each.value.export_policy_enabled
  quarantine_policy_enabled     = each.value.quarantine_policy_enabled
  retention_policy_in_days      = each.value.retention_policy_in_days
  trust_policy_enabled          = each.value.trust_policy_enabled
  identity                      = each.value.identity
  georeplications               = each.value.georeplications
  network_rule_set              = each.value.network_rule_set
  tags                          = each.value.tags
}
