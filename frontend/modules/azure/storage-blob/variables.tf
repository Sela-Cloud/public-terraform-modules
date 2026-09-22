variable "storage_blob" {
  description = "Map of Azure Storage Blob configurations to create."
  type = map(object({
    name                 = optional(string, "sample-blob.txt")
    storage_container_id = optional(string, "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-default/providers/Microsoft.Storage/storageAccounts/storagedefault/blobServices/default/containers/container-default")
    type                 = optional(string, "Block")
    size                 = optional(number, null)
    content_type         = optional(string, "application/octet-stream")
    source_content       = optional(string, null)
    source_file          = optional(string, null)
    source_uri           = optional(string, null)
    access_tier          = optional(string, "Hot")
    cache_control        = optional(string, null)
    content_md5          = optional(string, null)
    encryption_scope     = optional(string, null)
    parallelism          = optional(number, 8)
    metadata             = optional(map(string), {})
  }))
  default = {}
}
