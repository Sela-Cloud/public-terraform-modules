resource "azurerm_storage_blob" "storage_blob" {
  name                 = var.name
  storage_container_id = var.storage_container_id
  type                 = var.type
  size                 = var.size
  content_type         = var.content_type
  source_content       = var.source_content
  source               = var.source_file
  source_uri           = var.source_uri
  access_tier          = var.access_tier
  cache_control        = var.cache_control
  content_md5          = var.content_md5
  encryption_scope     = var.encryption_scope
  parallelism          = var.parallelism
  metadata             = length(var.metadata) > 0 ? var.metadata : null
}
