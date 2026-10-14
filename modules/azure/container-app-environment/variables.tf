variable "name" {
  description = "The name of the Container App Environment. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,30}[a-z0-9]$", var.name)) && length(var.name) >= 2 && length(var.name) <= 32
    error_message = "Container App Environment name must be between 2 and 32 characters, start and end with an alphanumeric character, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group where this Container App Environment should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The Azure Region where this Container App Environment should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to link this Container App Environment to. Required when logs_destination is set to 'log-analytics'."
  type        = string
  default     = null
}

variable "logs_destination" {
  description = "Where the logs are stored. Possible values include 'log-analytics', 'azure-monitor', and 'none'."
  type        = string
  default     = "log-analytics"

  validation {
    condition     = var.logs_destination == null || contains(["log-analytics", "azure-monitor", "none"], coalesce(var.logs_destination, "log-analytics"))
    error_message = "logs_destination must be one of 'log-analytics', 'azure-monitor', or 'none'."
  }
}

variable "infrastructure_subnet_id" {
  description = "The existing Subnet ID for the Container App Environment. Must have a delegation to Microsoft.App/environments and CIDR of at least /23 for consumption workload or /27 for dedicated workload."
  type        = string
  default     = null
}

variable "infrastructure_resource_group_name" {
  description = "Name of the platform-managed resource group created by Azure for infrastructure resources. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "internal_load_balancer_enabled" {
  description = "Should the Container Environment operate in Internal Load Balancing Mode? Defaults to false. Can only be set when infrastructure_subnet_id is specified."
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Should the Container App Environment be zone redundant? Defaults to false. Changing this forces a new resource to be created. Requires infrastructure_subnet_id."
  type        = bool
  default     = false
}

variable "mutual_tls_enabled" {
  description = "Should mutual TLS (mTLS) be enabled for the Container App Environment? Defaults to false."
  type        = bool
  default     = false
}

variable "public_network_access" {
  description = "Specifies public network access for the Container App Environment. Possible values are 'Enabled' and 'Disabled'."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "public_network_access must be either 'Enabled' or 'Disabled'."
  }
}

variable "dapr_application_insights_connection_string" {
  description = "Application Insights connection string used by Dapr to send telemetry."
  type        = string
  default     = null
  sensitive   = true
}

variable "workload_profiles" {
  description = "List of workload profile configurations for the Container App Environment."
  type = list(object({
    name                  = string
    workload_profile_type = string
    minimum_count         = optional(number, 0)
    maximum_count         = optional(number, 10)
  }))
  default = []
}

variable "identity" {
  description = "Managed Service Identity configuration for the Container App Environment."
  type = object({
    type         = string
    identity_ids = optional(list(string), null)
  })
  default = null

  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], try(var.identity.type, ""))
    error_message = "identity.type must be one of 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
