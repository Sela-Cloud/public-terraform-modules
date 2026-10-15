variable "name" {
  description = "The name which should be used for this Function App. Must be globally unique across Azure, 2-60 characters, and contain only alphanumeric characters and hyphens."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which the Function App should exist."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Function App should exist."
  type        = string
}

variable "os_type" {
  description = "The Operating System for this Function App. Possible values are 'Linux' and 'Windows'."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "The os_type must be either 'Linux' or 'Windows'."
  }
}

variable "create_service_plan" {
  description = "Whether to create a new App Service Plan. Set to false if attaching to an existing plan via 'service_plan_id'."
  type        = bool
  default     = true
}

variable "service_plan_name" {
  description = "The name of the App Service Plan to create. If null, defaults to 'asp-<name>'."
  type        = string
  default     = null
}

variable "service_plan_sku" {
  description = "The SKU for the Service Plan (e.g. 'Y1' for Consumption/Serverless, 'B1', 'S1', 'EP1')."
  type        = string
  default     = "Y1"
}

variable "service_plan_id" {
  description = "The ID of the existing App Service Plan to use. When specified, 'create_service_plan' is ignored."
  type        = string
  default     = null
}

variable "zone_balancing_enabled" {
  description = "Should the App Service Plan be zone redundant? (Requires Premium SKU)."
  type        = bool
  default     = false
}

variable "create_storage_account" {
  description = "Whether to create a new backend Azure Storage Account for the Function App."
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "The backend Storage Account name. If null and 'create_storage_account' is true, an auto-generated name is used."
  type        = string
  default     = null
}

variable "storage_account_access_key" {
  description = "The access key for the backend Storage Account. Required if 'create_storage_account' is false unless using managed identity."
  type        = string
  default     = null
  sensitive   = true
}

variable "storage_uses_managed_identity" {
  description = "Should the Function App use its Managed Identity to connect to the backend Storage Account?"
  type        = bool
  default     = false
}

variable "storage_account_tier" {
  description = "The Tier to use for the created Storage Account. Possible values are 'Standard' and 'Premium'."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "The replication type to use for the created Storage Account (e.g. 'LRS', 'GRS', 'ZRS')."
  type        = string
  default     = "LRS"
}

variable "https_only" {
  description = "Should the Function App require HTTPS traffic only?"
  type        = bool
  default     = true
}

variable "client_certificate_enabled" {
  description = "Should the Function App use client certificates (Mutual TLS)?"
  type        = bool
  default     = false
}

variable "client_certificate_mode" {
  description = "The mode of the Function App's client certificates. Possible values are 'Required', 'Optional', and 'OptionalInteractiveUser'."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Should public network access be enabled for the Function App?"
  type        = bool
  default     = true
}

variable "virtual_network_subnet_id" {
  description = "The ID of the subnet the Function App will use for regional Virtual Network integration."
  type        = string
  default     = null
}

variable "builtin_logging_enabled" {
  description = "Should built-in logging be enabled for the Function App?"
  type        = bool
  default     = true
}

variable "functions_extension_version" {
  description = "The runtime version of Azure Functions. Defaults to '~4'."
  type        = string
  default     = "~4"
}

variable "identity_type" {
  description = "The type of Managed Identity. Possible values are 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  type        = string
  default     = null

  validation {
    condition = var.identity_type == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], coalesce(var.identity_type, "null"))
    error_message = "Valid values for identity_type are 'SystemAssigned', 'UserAssigned', 'SystemAssigned, UserAssigned', or null."
  }
}

variable "identity_ids" {
  description = "A list of User Assigned Managed Identity IDs to be assigned to this Function App."
  type        = list(string)
  default     = []
}

variable "app_settings" {
  description = "A map of key-value pairs of App Settings (environment variables) for the Function App."
  type        = map(string)
  default     = {}
}

variable "site_config" {
  description = "Site configuration block for the Function App."
  type = object({
    always_on                = optional(bool)
    ftps_state               = optional(string, "FtpsOnly")
    minimum_tls_version      = optional(string, "1.2")
    http2_enabled            = optional(bool, false)
    app_scale_limit          = optional(number)
    elastic_instance_minimum = optional(number)

    application_stack = optional(object({
      dotnet_version              = optional(string)
      use_dotnet_isolated_runtime = optional(bool)
      node_version                = optional(string)
      python_version              = optional(string)
      java_version                = optional(string)
      powershell_core_version     = optional(string)
      use_custom_runtime          = optional(bool)
      docker = optional(object({
        image_name        = string
        image_tag         = string
        registry_url      = string
        registry_username = optional(string)
        registry_password = optional(string)
      }))
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
  description = "A list of connection strings for the Function App."
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
