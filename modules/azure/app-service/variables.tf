################################################################################
# Mandatory Variables (No Default Values)
################################################################################

variable "name" {
  description = "The name of the Azure App Service. Must be globally unique across Azure, 2-60 characters, and contain only alphanumeric characters and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$", var.name))
    error_message = "The App Service name must be 2-60 characters, begin and end with an alphanumeric character, and contain only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the App Service."
  type        = string
}

variable "location" {
  description = "The Azure Region where the App Service should exist."
  type        = string
}

################################################################################
# Optional Hosting & Service Plan Variables (With Default Values)
################################################################################

variable "os_type" {
  description = "The operating system type for the App Service and Service Plan. Valid values are 'Linux' or 'Windows'."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "The os_type must be either 'Linux' or 'Windows'."
  }
}

variable "create_service_plan" {
  description = "Whether to create a new App Service Plan. Set to false if supplying an existing service_plan_id."
  type        = bool
  default     = true
}

variable "service_plan_name" {
  description = "The name of the App Service Plan to create. If null, defaults to 'asp-<var.name>'."
  type        = string
  default     = null
}

variable "service_plan_sku" {
  description = "The SKU for the new App Service Plan (e.g. B1, B2, B3, S1, S2, S3, P1v3, P2v3, P3v3)."
  type        = string
  default     = "B1"
}

variable "service_plan_id" {
  description = "The resource ID of an existing App Service Plan to use. If provided, create_service_plan is automatically bypassed."
  type        = string
  default     = null
}

variable "zone_balancing_enabled" {
  description = "If true, the newly created Service Plan will balance instances across Availability Zones (requires Premium SKU)."
  type        = bool
  default     = false
}

################################################################################
# Optional Security & Networking Variables (With Default Values)
################################################################################

variable "https_only" {
  description = "Should all HTTP traffic be redirected to HTTPS?"
  type        = bool
  default     = true
}

variable "client_affinity_enabled" {
  description = "Should client affinity (ARR sticky cookies) be enabled?"
  type        = bool
  default     = false
}

variable "client_certificate_enabled" {
  description = "Should mutual TLS client certificate authentication be enabled?"
  type        = bool
  default     = false
}

variable "client_certificate_mode" {
  description = "The mode of client certificate requirement. Possible values are 'Required', 'Optional', or 'OptionalInteractiveUser'."
  type        = string
  default     = null

  validation {
    condition     = var.client_certificate_mode == null || contains(["Required", "Optional", "OptionalInteractiveUser"], coalesce(var.client_certificate_mode, "Required"))
    error_message = "The client_certificate_mode must be one of: Required, Optional, OptionalInteractiveUser."
  }
}

variable "public_network_access_enabled" {
  description = "Should public network access be enabled for this App Service?"
  type        = bool
  default     = true
}

variable "virtual_network_subnet_id" {
  description = "The ID of the Subnet to connect this App Service to for outbound regional VNet integration."
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The type of Managed Identity. Possible values are 'SystemAssigned', 'UserAssigned', 'SystemAssigned, UserAssigned', or null."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], coalesce(var.identity_type, "SystemAssigned"))
    error_message = "The identity_type must be one of: SystemAssigned, UserAssigned, 'SystemAssigned, UserAssigned', or null."
  }
}

variable "identity_ids" {
  description = "List of User Assigned Identity IDs when identity_type includes UserAssigned."
  type        = list(string)
  default     = []
}

variable "app_settings" {
  description = "A map of key-value pairs representing App Settings / environment variables."
  type        = map(string)
  default     = {}
}

################################################################################
# Optional Site Configuration & Sub-Resource Blocks (With Default Values)
################################################################################

variable "site_config" {
  description = "Site configuration for the App Service."
  type = object({
    always_on                         = optional(bool, null)
    ftps_state                        = optional(string, "FtpsOnly")
    minimum_tls_version               = optional(string, "1.2")
    http2_enabled                     = optional(bool, false)
    health_check_path                 = optional(string)
    health_check_eviction_time_in_min = optional(number)

    application_stack = optional(object({
      dotnet_version      = optional(string)
      node_version        = optional(string)
      python_version      = optional(string)
      java_version        = optional(string)
      php_version         = optional(string)
      docker_image_name   = optional(string)
      docker_registry_url = optional(string)
    }))

    cors = optional(object({
      allowed_origins     = optional(list(string), [])
      support_credentials = optional(bool, false)
    }))

    ip_restriction = optional(list(object({
      name                      = optional(string)
      ip_address                = optional(string)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      priority                  = optional(number, 100)
      action                    = optional(string, "Allow")
      description               = optional(string)
    })), [])

    scm_ip_restriction = optional(list(object({
      name                      = optional(string)
      ip_address                = optional(string)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      priority                  = optional(number, 100)
      action                    = optional(string, "Allow")
      description               = optional(string)
    })), [])
  })
  default = {}
}

variable "connection_strings" {
  description = "List of connection strings for the App Service."
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}

variable "storage_mounts" {
  description = "List of storage accounts to mount as custom shares."
  type = list(object({
    name         = string
    type         = string
    account_name = string
    share_name   = string
    access_key   = string
    mount_path   = string
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the App Service."
  type        = map(string)
  default     = {}
}
