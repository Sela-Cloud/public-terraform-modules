variable "frontdoor" {
  description = "Map of Azure Front Door profiles to provision."
  type = map(object({
    name                     = string
    resource_group_name      = string
    sku_name                 = optional(string, "Standard_AzureFrontDoor")
    response_timeout_seconds = optional(number, 120)
    endpoints = list(object({
      name    = string
      enabled = optional(bool, true)
      tags    = optional(map(string), {})
    }))
    origin_groups = list(object({
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
    routes = list(object({
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
    tags = optional(map(string), {})
  }))
  default = {}
}
