variable "storage_account" {
  description = "Map of Azure Storage Account configurations to create."
  type = map(object({
    name                              = optional(string, "stdefault001")
    resource_group_name               = optional(string, "rg-default")
    location                          = optional(string, "eastus")
    account_tier                      = optional(string, "Standard")
    account_replication_type          = optional(string, "LRS")
    account_kind                      = optional(string, "StorageV2")
    access_tier                       = optional(string, "Hot")
    edge_zone                         = optional(string, null)
    https_traffic_only_enabled        = optional(bool, true)
    min_tls_version                   = optional(string, "TLS1_2")
    allow_nested_items_to_be_public   = optional(bool, false)
    shared_access_key_enabled         = optional(bool, true)
    public_network_access_enabled     = optional(bool, true)
    default_to_oauth_authentication   = optional(bool, false)
    is_hns_enabled                    = optional(bool, false)
    nfsv3_enabled                     = optional(bool, false)
    large_file_share_enabled          = optional(bool, false)
    cross_tenant_replication_enabled  = optional(bool, false)
    infrastructure_encryption_enabled = optional(bool, false)
    sftp_enabled                      = optional(bool, false)
    network_rules = optional(object({
      default_action             = optional(string, "Allow")
      bypass                     = optional(list(string), ["AzureServices"])
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), null)
    blob_properties = optional(object({
      versioning_enabled                     = optional(bool, false)
      change_feed_enabled                    = optional(bool, false)
      delete_retention_policy_days           = optional(number, null)
      container_delete_retention_policy_days = optional(number, null)
    }), null)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}
