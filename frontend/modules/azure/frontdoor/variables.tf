variable "frontdoor" {
  description = "Map of Azure Front Door (Classic) configurations."
  type = map(object({
    name                  = string
    resource_group_name   = string
    friendly_name         = optional(string, null)
    load_balancer_enabled = optional(bool, true)

    frontend_endpoints = list(object({
      name                                    = string
      host_name                               = string
      session_affinity_enabled                = optional(bool, false)
      session_affinity_ttl_seconds            = optional(number, 0)
      web_application_firewall_policy_link_id = optional(string, null)
    }))

    backend_pools = list(object({
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

    backend_pool_load_balancing = optional(list(object({
      name                                    = string
      sample_size                             = optional(number, 4)
      successful_samples_required             = optional(number, 2)
      additional_latency_enforce_milliseconds = optional(number, 0)
    })), [
      {
        name                                    = "defaultLoadBalancingSettings"
        sample_size                             = 4
        successful_samples_required             = 2
        additional_latency_enforce_milliseconds = 0
      }
    ])

    backend_pool_health_probes = optional(list(object({
      name                = string
      enabled             = optional(bool, true)
      path                = optional(string, "/")
      protocol            = optional(string, "Http")
      probe_method        = optional(string, "HEAD")
      interval_in_seconds = optional(number, 120)
    })), [
      {
        name                = "defaultHealthProbeSettings"
        enabled             = true
        path                = "/"
        protocol            = "Http"
        probe_method        = "HEAD"
        interval_in_seconds = 120
      }
    ])

    routing_rules = list(object({
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

    tags = optional(map(string), {})
  }))
  default = {}
}
