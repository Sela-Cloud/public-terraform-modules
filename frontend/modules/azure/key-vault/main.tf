module "key_vault" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/key-vault?ref=v0.7.6"
  for_each = var.key_vault

  name                            = each.value.name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  sku_name                        = each.value.sku_name
  tenant_id                       = each.value.tenant_id
  rbac_authorization_enabled      = each.value.rbac_authorization_enabled
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  purge_protection_enabled        = each.value.purge_protection_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  public_network_access_enabled   = each.value.public_network_access_enabled
  network_acls                    = each.value.network_acls
  access_policies                 = each.value.access_policies
  tags                            = each.value.tags
}
