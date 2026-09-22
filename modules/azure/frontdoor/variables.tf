variable "name" {
  description = "(Required) Specifies the name of the Front Door service. Changing this forces a new resource to be created. Must be globally unique, between 5 and 64 characters."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{3,62}[a-zA-Z0-9]$", var.name))
    error_message = "The Front Door name must be between 5 and 64 characters, begin and end with an alphanumeric character, and contain only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the Resource Group in which the Front Door service should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "frontend_endpoints" {
  description = "(Required) A list of frontend_endpoint blocks configuring the hostnames used to access the Front Door."
  type = list(object({
    name                                    = string
    host_name                               = string
    session_affinity_enabled                = optional(bool, false)
    session_affinity_ttl_seconds            = optional(number, 0)
    web_application_firewall_policy_link_id = optional(string, null)
  }))
}

variable "backend_pools" {
  description = "(Required) A list of backend_pool blocks configuring the backends that receive traffic from the Front Door."
  type = list(object({
    name                = string
    load_balancing_name = string
    health_probe_name   = string
    backends = list(object({
      enabled     = optional(bool, true)
      address     = string
      host_header = string
      http_port   = optional(number, 80)
      https_port  = optional(number, 443)
      priority    = optional(number, 1)
      weight      = optional(number, 50)
    }))
  }))
}

variable "routing_rules" {
  description = "(Required) A list of routing_rule blocks connecting frontend endpoints to backend pools or redirecting traffic."
  type = list(object({
    name               = string
    accepted_protocols = optional(list(string), ["Http", "Https"])
    patterns_to_match  = optional(list(string), ["/*"])
    frontend_endpoints = list(string)
    forwarding_configuration = optional(object({
      backend_pool_name                     = string
      forwarding_protocol                   = optional(string, "MatchRequest")
      cache_enabled                         = optional(bool, false)
      cache_use_dynamic_compression         = optional(bool, false)
      cache_query_parameter_strip_directive = optional(string, "StripAll")
      cache_query_parameters                = optional(list(string), [])
      cache_duration                        = optional(string, null)
      custom_forwarding_path                = optional(string, null)
    }), null)
    redirect_configuration = optional(object({
      custom_host         = optional(string, null)
      redirect_type       = string
      redirect_protocol   = string
      custom_path         = optional(string, null)
      custom_fragment     = optional(string, null)
      custom_query_string = optional(string, null)
    }), null)
  }))
}

variable "friendly_name" {
  description = "(Optional) A friendly name for the Front Door service. Defaults to null."
  type        = string
  default     = null
}

variable "load_balancer_enabled" {
  description = "(Optional) Should the Front Door Load Balancer be enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "backend_pool_load_balancing" {
  description = "(Optional) A list of backend_pool_load_balancing blocks. Defaults to standard load balancing settings."
  type = list(object({
    name                                    = string
    sample_size                             = optional(number, 4)
    successful_samples_required             = optional(number, 2)
    additional_latency_enforce_milliseconds = optional(number, 0)
  }))
  default = [
    {
      name                                    = "defaultLoadBalancingSettings"
      sample_size                             = 4
      successful_samples_required             = 2
      additional_latency_enforce_milliseconds = 0
    }
  ]
}

variable "backend_pool_health_probes" {
  description = "(Optional) A list of backend_pool_health_probe blocks. Defaults to standard health probe settings."
  type = list(object({
    name                = string
    enabled             = optional(bool, true)
    path                = optional(string, "/")
    protocol            = optional(string, "Http")
    probe_method        = optional(string, "HEAD")
    interval_in_seconds = optional(number, 120)
  }))
  default = [
    {
      name                = "defaultHealthProbeSettings"
      enabled             = true
      path                = "/"
      protocol            = "Http"
      probe_method        = "HEAD"
      interval_in_seconds = 120
    }
  ]
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the Front Door resource. Defaults to {}."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "(Optional) Custom timeout durations for resource operations."
  type = object({
    create = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}
