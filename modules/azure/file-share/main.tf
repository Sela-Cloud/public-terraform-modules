resource "azurerm_storage_share" "share" {
  name               = var.name
  storage_account_id = var.storage_account_id
  quota              = var.quota
  access_tier        = var.access_tier
  enabled_protocol   = var.enabled_protocol
  metadata           = length(var.metadata) > 0 ? var.metadata : null

  dynamic "acl" {
    for_each = var.acl
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = acl.value.access_policy != null ? [acl.value.access_policy] : []
        content {
          permissions = access_policy.value.permissions
          start       = access_policy.value.start
          expiry      = access_policy.value.expiry
        }
      }
    }
  }
}
