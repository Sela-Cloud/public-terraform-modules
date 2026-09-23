variable "container_registry" {
  description = "Map of Azure Container Registry configurations to create."
  type = map(object({
    name                          = optional(string, "crdefault123")
    resource_group_name           = optional(string, "rg-default")
    location                      = optional(string, "eastus")
    sku                           = optional(string, "Standard")
    admin_enabled                 = optional(bool, false)
    public_network_access_enabled = optional(bool, true)
    network_rule_bypass_option    = optional(string, "AzureServices")
    zone_redundancy_enabled       = optional(bool, false)
    anonymous_pull_enabled        = optional(bool, false)
    data_endpoint_enabled         = optional(bool, false)
    export_policy_enabled         = optional(bool, true)
    quarantine_policy_enabled     = optional(bool, false)
    retention_policy_in_days      = optional(number, null)
    trust_policy_enabled          = optional(bool, false)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), null)
    }), null)
    georeplications = optional(list(object({
      location                  = string
      regional_endpoint_enabled = optional(bool, null)
      zone_redundancy_enabled   = optional(bool, null)
      tags                      = optional(map(string), {})
    })), [])
    network_rule_set = optional(object({
      default_action = optional(string, "Allow")
      ip_rule = optional(list(object({
        action   = string
        ip_range = string
      })), [])
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}
