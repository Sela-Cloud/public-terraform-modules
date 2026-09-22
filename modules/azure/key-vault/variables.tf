variable "name" {
  description = "(Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created. The name must be globally unique, 3-24 characters, and only contain alphanumeric characters and hyphens, starting with a letter and ending with a letter or digit."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "The Key Vault name must be between 3 and 24 characters, begin with a letter, end with a letter or digit, and contain only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Key Vault. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the Key Vault should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The sku_name must be either 'standard' or 'premium'."
  }
}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
  type        = string
}

variable "rbac_authorization_enabled" {
  description = "(Required) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
}

variable "enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  type        = bool
  default     = false
}

variable "purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault? Defaults to false. Once purge protection is enabled for a key vault, it cannot be disabled."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the Azure default: 90) days. Defaults to 90."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "The soft_delete_retention_days must be between 7 and 90 days."
  }
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this Key Vault. Defaults to true."
  type        = bool
  default     = true
}

variable "network_acls" {
  description = "(Optional) A network_acls block to restrict access to the Key Vault. Defaults to null."
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(string, "AzureServices")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.network_acls == null ? true : (
      contains(["Allow", "Deny"], var.network_acls.default_action) &&
      contains(["AzureServices", "None"], var.network_acls.bypass)
    )
    error_message = "The network_acls default_action must be 'Allow' or 'Deny', and bypass must be 'AzureServices' or 'None'."
  }
}

variable "access_policies" {
  description = "(Optional) A list of access_policy objects describing access policies for the Key Vault. Defaults to []."
  type = list(object({
    tenant_id               = string
    object_id               = string
    application_id          = optional(string, null)
    certificate_permissions = optional(list(string), [])
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = []
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the Key Vault. Defaults to {}."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "(Optional) Custom timeout durations for Key Vault operations."
  type = object({
    create = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}
