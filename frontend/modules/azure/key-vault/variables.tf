variable "key_vault" {
  description = "Map of Azure Key Vault configurations."
  type = map(object({
    name                            = string
    resource_group_name             = string
    location                        = string
    sku_name                        = string
    tenant_id                       = string
    rbac_authorization_enabled      = bool
    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    purge_protection_enabled        = optional(bool, false)
    soft_delete_retention_days      = optional(number, 90)
    public_network_access_enabled   = optional(bool, true)
    network_acls = optional(object({
      default_action             = optional(string, "Deny")
      bypass                     = optional(string, "AzureServices")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), null)
    access_policies = optional(list(object({
      tenant_id               = string
      object_id               = string
      application_id          = optional(string, null)
      certificate_permissions = optional(list(string), [])
      key_permissions         = optional(list(string), [])
      secret_permissions      = optional(list(string), [])
      storage_permissions     = optional(list(string), [])
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
