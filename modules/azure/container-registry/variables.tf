variable "name" {
  description = "The name of the Container Registry. Only alphanumeric characters allowed. Must be globally unique."
  type        = string
  default     = "crdefault123"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "Container Registry name must be between 5 and 50 characters and contain only alphanumeric characters."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90 && can(regex("^[-\\w\\._\\(\\)]+[^\\.]$", var.resource_group_name))
    error_message = "Resource group name must be between 1 and 90 characters, consist of alphanumerics, underscores, parentheses, hyphens, and periods, and cannot end in a period."
  }
}

variable "location" {
  description = "The Azure Region where the Container Registry should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "sku" {
  description = "The SKU name of the container registry. Possible values are 'Basic', 'Standard', and 'Premium'."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of 'Basic', 'Standard', or 'Premium'."
  }
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the container registry."
  type        = bool
  default     = true
}

variable "network_rule_bypass_option" {
  description = "Whether to allow trusted Azure services to access a network restricted Container Registry. Possible values are 'AzureServices' and 'None'."
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.network_rule_bypass_option)
    error_message = "network_rule_bypass_option must be either 'AzureServices' or 'None'."
  }
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for this Container Registry. Only supported on Premium SKU."
  type        = bool
  default     = false
}

variable "anonymous_pull_enabled" {
  description = "Whether anonymous (unauthenticated) pull access is allowed. Only supported on Standard and Premium SKU."
  type        = bool
  default     = false
}

variable "data_endpoint_enabled" {
  description = "Whether to enable dedicated data endpoints for this Container Registry. Only supported on Premium SKU."
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = "Boolean value that indicates whether export policy is enabled."
  type        = bool
  default     = true
}

variable "quarantine_policy_enabled" {
  description = "Boolean value that indicates whether quarantine policy is enabled. Only supported on Premium SKU."
  type        = bool
  default     = false
}

variable "retention_policy_in_days" {
  description = "The number of days to retain untagged manifests after which they are purged. Only supported on Premium SKU."
  type        = number
  default     = null
}

variable "trust_policy_enabled" {
  description = "Boolean value that indicates whether the policy is enabled for content trust. Only supported on Premium SKU."
  type        = bool
  default     = false
}

variable "identity" {
  description = "Managed Identity configuration block for the Container Registry."
  type = object({
    type         = string
    identity_ids = optional(list(string), null)
  })
  default = null
}

variable "georeplications" {
  description = "A list of geo-replication configurations for the Container Registry. Only supported on Premium SKU."
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, null)
    zone_redundancy_enabled   = optional(bool, null)
    tags                      = optional(map(string), {})
  }))
  default = []
}

variable "network_rule_set" {
  description = "Network rule set configuration block for the Container Registry. Only supported on Premium SKU."
  type = object({
    default_action = optional(string, "Allow")
    ip_rule = optional(list(object({
      action   = string
      ip_range = string
    })), [])
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Container Registry."
  type        = map(string)
  default     = {}
}
