variable "name" {
  description = "Specifies the name of the storage account. Only lowercase alphanumeric characters allowed. Must be between 3 and 24 characters. Changing this forces a new resource to be created."
  type        = string
  default     = "stdefault001"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage Account name must be between 3 and 24 characters and contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are 'Standard' and 'Premium'."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Possible values are 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', and 'RAGZRS'."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', or 'RAGZRS'."
  }
}

variable "account_kind" {
  description = "Defines the Kind of account. Valid options are 'BlobStorage', 'BlockBlobStorage', 'FileStorage', 'Storage', and 'StorageV2'."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "account_kind must be one of 'BlobStorage', 'BlockBlobStorage', 'FileStorage', 'Storage', or 'StorageV2'."
  }
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are 'Hot', 'Cool', and 'Cold'."
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool", "Cold"], var.access_tier)
    error_message = "access_tier must be one of 'Hot', 'Cool', or 'Cold'."
  }
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Storage Account should exist."
  type        = string
  default     = null
}

variable "https_traffic_only_enabled" {
  description = "Boolean flag which forces HTTPS if enabled."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account. The only possible value is 'TLS1_2'."
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = var.min_tls_version == "TLS1_2"
    error_message = "min_tls_version must be 'TLS1_2'."
  }
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the storage account. Defaults to true."
  type        = bool
  default     = true
}

variable "default_to_oauth_authentication" {
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account."
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2."
  type        = bool
  default     = false
}

variable "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "large_file_share_enabled" {
  description = "Are Large File Shares Enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "cross_tenant_replication_enabled" {
  description = "Should cross Tenant replication be enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "sftp_enabled" {
  description = "Boolean, enable SFTP for the storage account. SFTP support requires is_hns_enabled set to true."
  type        = bool
  default     = false
}

variable "network_rules" {
  description = "Network rules restricting access to the storage account."
  type = object({
    default_action             = optional(string, "Allow")
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "blob_properties" {
  description = "Blob service properties including versioning, change feed, and delete retention."
  type = object({
    versioning_enabled                     = optional(bool, false)
    change_feed_enabled                    = optional(bool, false)
    delete_retention_policy_days           = optional(number, null)
    container_delete_retention_policy_days = optional(number, null)
  })
  default = null
}

variable "identity" {
  description = "Managed Service Identity configuration for the storage account."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
