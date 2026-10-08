variable "application_gateway" {
  description = "Map of Azure Application Gateway configurations."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string

    sku = optional(object({
      name     = string
      tier     = string
      capacity = optional(number, null)
      }), {
      name     = "Standard_v2"
      tier     = "Standard_v2"
      capacity = null
    })

    autoscale_configuration = optional(object({
      min_capacity = number
      max_capacity = optional(number, null)
      }), {
      min_capacity = 1
      max_capacity = 10
    })

    gateway_ip_configurations = list(object({
      name      = string
      subnet_id = string
    }))

    frontend_ip_configurations = list(object({
      name                            = string
      subnet_id                       = optional(string, null)
      private_ip_address              = optional(string, null)
      private_ip_address_allocation   = optional(string, null)
      public_ip_address_id            = optional(string, null)
      private_link_configuration_name = optional(string, null)
    }))

    frontend_ports = list(object({
      name = string
      port = number
    }))

    backend_address_pools = list(object({
      name         = string
      fqdns        = optional(list(string), null)
      ip_addresses = optional(list(string), null)
    }))

    backend_http_settings = list(object({
      name                                = string
      cookie_based_affinity               = optional(string, "Disabled")
      affinity_cookie_name                = optional(string, null)
      path                                = optional(string, null)
      port                                = number
      protocol                            = optional(string, "Http")
      request_timeout                     = optional(number, 60)
      probe_name                          = optional(string, null)
      host_name                           = optional(string, null)
      pick_host_name_from_backend_address = optional(bool, false)
      trusted_root_certificate_names      = optional(list(string), null)
      connection_draining = optional(object({
        enabled           = bool
        drain_timeout_sec = number
      }), null)
    }))

    http_listeners = list(object({
      name                           = string
      frontend_ip_configuration_name = string
      frontend_port_name             = string
      protocol                       = optional(string, "Http")
      host_name                      = optional(string, null)
      host_names                     = optional(list(string), null)
      require_sni                    = optional(bool, false)
      ssl_certificate_name           = optional(string, null)
      ssl_profile_name               = optional(string, null)
      firewall_policy_id             = optional(string, null)
      custom_error_configuration = optional(list(object({
        status_code           = string
        custom_error_page_url = string
      })), [])
    }))

    request_routing_rules = list(object({
      name                        = string
      rule_type                   = optional(string, "Basic")
      http_listener_name          = string
      backend_address_pool_name   = optional(string, null)
      backend_http_settings_name  = optional(string, null)
      redirect_configuration_name = optional(string, null)
      rewrite_rule_set_name       = optional(string, null)
      url_path_map_name           = optional(string, null)
      priority                    = optional(number, null)
    }))

    probes = optional(list(object({
      name                                      = string
      protocol                                  = string
      path                                      = string
      host                                      = optional(string, null)
      interval                                  = optional(number, 30)
      timeout                                   = optional(number, 30)
      unhealthy_threshold                       = optional(number, 3)
      port                                      = optional(number, null)
      pick_host_name_from_backend_http_settings = optional(bool, false)
      minimum_servers                           = optional(number, null)
      match = optional(object({
        body        = optional(string, null)
        status_code = optional(list(string), null)
      }), null)
    })), [])

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), null)
    }), null)

    ssl_certificates = optional(list(object({
      name                = string
      data                = optional(string, null)
      password            = optional(string, null)
      key_vault_secret_id = optional(string, null)
    })), [])

    ssl_policy = optional(object({
      policy_type          = optional(string, null)
      policy_name          = optional(string, null)
      min_protocol_version = optional(string, null)
      cipher_suites        = optional(list(string), null)
      disabled_protocols   = optional(list(string), null)
    }), null)

    trusted_root_certificates = optional(list(object({
      name                = string
      data                = optional(string, null)
      key_vault_secret_id = optional(string, null)
    })), [])

    redirect_configurations = optional(list(object({
      name                 = string
      redirect_type        = string
      target_listener_name = optional(string, null)
      target_url           = optional(string, null)
      include_path         = optional(bool, false)
      include_query_string = optional(bool, false)
    })), [])

    url_path_maps = optional(list(object({
      name                                = string
      default_backend_address_pool_name   = optional(string, null)
      default_backend_http_settings_name  = optional(string, null)
      default_redirect_configuration_name = optional(string, null)
      default_rewrite_rule_set_name       = optional(string, null)
      path_rules = list(object({
        name                        = string
        paths                       = list(string)
        backend_address_pool_name   = optional(string, null)
        backend_http_settings_name  = optional(string, null)
        redirect_configuration_name = optional(string, null)
        rewrite_rule_set_name       = optional(string, null)
        firewall_policy_id          = optional(string, null)
      }))
    })), [])

    rewrite_rule_sets = optional(list(object({
      name = string
      rewrite_rules = optional(list(object({
        name          = string
        rule_sequence = number
        conditions = optional(list(object({
          variable    = string
          pattern     = string
          ignore_case = optional(bool, false)
          negate      = optional(bool, false)
        })), [])
        request_header_configurations = optional(list(object({
          header_name  = string
          header_value = string
        })), [])
        response_header_configurations = optional(list(object({
          header_name  = string
          header_value = string
        })), [])
        url = optional(object({
          path         = optional(string, null)
          query_string = optional(string, null)
          reroute      = optional(bool, null)
          components   = optional(string, null)
        }), null)
      })), [])
    })), [])

    waf_configuration = optional(object({
      enabled                  = bool
      firewall_mode            = string
      rule_set_version         = string
      rule_set_type            = optional(string, "OWASP")
      file_upload_limit_mb     = optional(number, 100)
      max_request_body_size_kb = optional(number, 128)
      request_body_check       = optional(bool, true)
      disabled_rule_groups = optional(list(object({
        rule_group_name = string
        rules           = optional(list(string), null)
      })), [])
      exclusions = optional(list(object({
        match_variable          = string
        selector                = optional(string, null)
        selector_match_operator = optional(string, null)
      })), [])
    }), null)

    zones                             = optional(list(string), null)
    http2_enabled                     = optional(bool, true)
    fips_enabled                      = optional(bool, null)
    firewall_policy_id                = optional(string, null)
    force_firewall_policy_association = optional(bool, null)
    global = optional(object({
      request_buffering_enabled  = bool
      response_buffering_enabled = bool
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}
