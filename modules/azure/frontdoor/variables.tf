variable "name" {
  description = "(Required) Specifies the name of the Front Door profile. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,62}[a-zA-Z0-9]$", var.name))
    error_message = "The Front Door name must be between 3 and 64 characters, begin and end with an alphanumeric character, and contain only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the Resource Group in which the Front Door profile should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "sku_name" {
  description = "(Optional) Specifies the SKU for the Front Door profile. Possible values are 'Standard_AzureFrontDoor' and 'Premium_AzureFrontDoor'. Defaults to 'Standard_AzureFrontDoor'."
  type        = string
  default     = "Standard_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku_name)
    error_message = "sku_name must be either 'Standard_AzureFrontDoor' or 'Premium_AzureFrontDoor'."
  }
}

variable "response_timeout_seconds" {
  description = "(Optional) Specifies the maximum response timeout in seconds. Possible values are between 16 and 240 seconds. Defaults to 120."
  type        = number
  default     = 120

  validation {
    condition     = var.response_timeout_seconds >= 16 && var.response_timeout_seconds <= 240
    error_message = "response_timeout_seconds must be between 16 and 240 seconds."
  }
}

variable "endpoints" {
  description = "(Required) A list of endpoint configurations for the Front Door profile."
  type = list(object({
    name    = string
    enabled = optional(bool, true)
    tags    = optional(map(string), {})
  }))
}

variable "origin_groups" {
  description = "(Required) A list of origin group configurations, each containing one or more backend origins."
  type = list(object({
    name                                                      = string
    session_affinity_enabled                                  = optional(bool, false)
    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, null)
    load_balancing = optional(object({
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
      additional_latency_in_milliseconds = optional(number, 50)
    }), {})
    health_probe = optional(object({
      protocol            = optional(string, "Https")
      interval_in_seconds = optional(number, 100)
      path                = optional(string, "/")
      request_type        = optional(string, "HEAD")
    }), {})
    origins = list(object({
      name                           = string
      host_name                      = string
      origin_host_header             = optional(string, null)
      http_port                      = optional(number, 80)
      https_port                     = optional(number, 443)
      priority                       = optional(number, 1)
      weight                         = optional(number, 1000)
      certificate_name_check_enabled = optional(bool, true)
      enabled                        = optional(bool, true)
    }))
  }))
}

variable "routes" {
  description = "(Required) A list of route configurations connecting endpoints to origin groups."
  type = list(object({
    name                   = string
    endpoint_name          = string
    origin_group_name      = string
    forwarding_protocol    = optional(string, "HttpsOnly")
    patterns_to_match      = optional(list(string), ["/*"])
    supported_protocols    = optional(list(string), ["Http", "Https"])
    https_redirect_enabled = optional(bool, true)
    link_to_default_domain = optional(bool, true)
    cache = optional(object({
      query_string_caching_behavior = optional(string, "IgnoreQueryString")
      query_strings                 = optional(list(string), null)
      compression_enabled           = optional(bool, false)
      content_types_to_compress     = optional(list(string), null)
    }), null)
  }))
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the Front Door profile. Defaults to {}."
  type        = map(string)
  default     = {}
}
