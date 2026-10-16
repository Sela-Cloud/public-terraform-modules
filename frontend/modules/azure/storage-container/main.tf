module "storage_container" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/storage-container?ref=v0.9.17"
  for_each = var.storage_container

  name                              = each.value.name
  storage_account_id                = each.value.storage_account_id
  container_access_type             = each.value.container_access_type
  default_encryption_scope          = each.value.default_encryption_scope
  encryption_scope_override_enabled = each.value.encryption_scope_override_enabled
  metadata                          = each.value.metadata
  blobs                             = each.value.blobs
}
