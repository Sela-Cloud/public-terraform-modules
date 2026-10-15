locals {
  storage_account_name = element(split("/", var.storage_account_id), length(split("/", var.storage_account_id)) - 1)
}

resource "azurerm_storage_container" "container" {
  name                              = var.name
  storage_account_id                = var.storage_account_id
  container_access_type             = var.container_access_type
  default_encryption_scope          = var.default_encryption_scope
  encryption_scope_override_enabled = var.encryption_scope_override_enabled
  metadata                          = length(var.metadata) > 0 ? var.metadata : null
}

resource "azurerm_storage_blob" "blobs" {
  for_each               = { for b in var.blobs : b.name => b }
  name                   = each.value.name
  storage_account_name   = local.storage_account_name
  storage_container_name = azurerm_storage_container.container.name
  type                   = coalesce(each.value.type, "Block")
  size                   = each.value.size
  content_type           = each.value.content_type
  source_content         = each.value.source_content
  source                 = each.value.source_file
  source_uri             = each.value.source_uri
  access_tier            = each.value.access_tier
  cache_control          = each.value.cache_control
  content_md5            = each.value.content_md5
  metadata               = length(each.value.metadata) > 0 ? each.value.metadata : null
}
