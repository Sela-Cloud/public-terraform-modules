module "file_share" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/file-share?ref=v0.9.13"
  for_each = var.file_share

  name               = each.value.name
  storage_account_id = each.value.storage_account_id
  quota              = each.value.quota
  access_tier        = each.value.access_tier
  enabled_protocol   = each.value.enabled_protocol
  metadata           = each.value.metadata
  acl                = each.value.acl
}
