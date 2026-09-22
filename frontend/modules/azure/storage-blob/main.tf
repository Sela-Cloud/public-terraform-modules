module "storage_blob" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/storage-blob?ref=v0.7.6"
  for_each = var.storage_blob

  name                 = each.value.name
  storage_container_id = each.value.storage_container_id
  type                 = each.value.type
  size                 = each.value.size
  content_type         = each.value.content_type
  source_content       = each.value.source_content
  source_file          = each.value.source_file
  source_uri           = each.value.source_uri
  access_tier          = each.value.access_tier
  cache_control        = each.value.cache_control
  content_md5          = each.value.content_md5
  encryption_scope     = each.value.encryption_scope
  parallelism          = each.value.parallelism
  metadata             = each.value.metadata
}
