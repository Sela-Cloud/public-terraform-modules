resource "azurerm_application_gateway" "app_gateway" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  zones                             = var.zones
  http2_enabled                     = var.http2_enabled
  fips_enabled                      = var.fips_enabled
  firewall_policy_id                = var.firewall_policy_id
  force_firewall_policy_association = var.force_firewall_policy_association
  tags                              = var.tags

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.autoscale_configuration == null ? (var.sku.capacity != null ? var.sku.capacity : 2) : null
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [var.autoscale_configuration] : []
    content {
      min_capacity = autoscale_configuration.value.min_capacity
      max_capacity = autoscale_configuration.value.max_capacity
    }
  }

  dynamic "gateway_ip_configuration" {
    for_each = var.gateway_ip_configurations
    content {
      name      = gateway_ip_configuration.value.name
      subnet_id = gateway_ip_configuration.value.subnet_id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                            = frontend_ip_configuration.value.name
      subnet_id                       = frontend_ip_configuration.value.subnet_id
      private_ip_address              = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation   = frontend_ip_configuration.value.private_ip_address_allocation
      public_ip_address_id            = frontend_ip_configuration.value.public_ip_address_id
      private_link_configuration_name = frontend_ip_configuration.value.private_link_configuration_name
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      path                                = backend_http_settings.value.path
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      probe_name                          = backend_http_settings.value.probe_name
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      trusted_root_certificate_names      = backend_http_settings.value.trusted_root_certificate_names

      dynamic "connection_draining" {
        for_each = backend_http_settings.value.connection_draining != null ? [backend_http_settings.value.connection_draining] : []
        content {
          enabled           = connection_draining.value.enabled
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
        }
      }
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
      host_names                     = http_listener.value.host_names
      require_sni                    = http_listener.value.require_sni
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      ssl_profile_name               = http_listener.value.ssl_profile_name
      firewall_policy_id             = http_listener.value.firewall_policy_id

      dynamic "custom_error_configuration" {
        for_each = coalesce(http_listener.value.custom_error_configuration, [])
        content {
          status_code           = custom_error_configuration.value.status_code
          custom_error_page_url = custom_error_configuration.value.custom_error_page_url
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                        = request_routing_rule.value.name
      rule_type                   = request_routing_rule.value.rule_type
      http_listener_name          = request_routing_rule.value.http_listener_name
      backend_address_pool_name   = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name  = request_routing_rule.value.backend_http_settings_name
      redirect_configuration_name = request_routing_rule.value.redirect_configuration_name
      rewrite_rule_set_name       = request_routing_rule.value.rewrite_rule_set_name
      url_path_map_name           = request_routing_rule.value.url_path_map_name
      priority                    = request_routing_rule.value.priority
    }
  }

  dynamic "probe" {
    for_each = var.probes
    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = probe.value.host
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      port                                      = probe.value.port
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      minimum_servers                           = probe.value.minimum_servers

      dynamic "match" {
        for_each = probe.value.match != null ? [probe.value.match] : []
        content {
          body        = match.value.body
          status_code = match.value.status_code
        }
      }
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = ssl_certificate.value.data
      password            = ssl_certificate.value.password
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "ssl_policy" {
    for_each = var.ssl_policy != null ? [var.ssl_policy] : []
    content {
      policy_type          = ssl_policy.value.policy_type
      policy_name          = ssl_policy.value.policy_name
      min_protocol_version = ssl_policy.value.min_protocol_version
      cipher_suites        = ssl_policy.value.cipher_suites
      disabled_protocols   = ssl_policy.value.disabled_protocols
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificates
    content {
      name                = trusted_root_certificate.value.name
      data                = trusted_root_certificate.value.data
      key_vault_secret_id = trusted_root_certificate.value.key_vault_secret_id
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.redirect_configurations
    content {
      name                 = redirect_configuration.value.name
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_maps
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name  = url_path_map.value.default_backend_http_settings_name
      default_redirect_configuration_name = url_path_map.value.default_redirect_configuration_name
      default_rewrite_rule_set_name       = url_path_map.value.default_rewrite_rule_set_name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules
        content {
          name                        = path_rule.value.name
          paths                       = path_rule.value.paths
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          redirect_configuration_name = path_rule.value.redirect_configuration_name
          rewrite_rule_set_name       = path_rule.value.rewrite_rule_set_name
          firewall_policy_id          = path_rule.value.firewall_policy_id
        }
      }
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_sets
    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = coalesce(rewrite_rule_set.value.rewrite_rules, [])
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = coalesce(rewrite_rule.value.conditions, [])
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = coalesce(rewrite_rule.value.request_header_configurations, [])
            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = coalesce(rewrite_rule.value.response_header_configurations, [])
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

          dynamic "url" {
            for_each = rewrite_rule.value.url != null ? [rewrite_rule.value.url] : []
            content {
              path         = url.value.path
              query_string = url.value.query_string
              reroute      = url.value.reroute
              components   = url.value.components
            }
          }
        }
      }
    }
  }

  dynamic "waf_configuration" {
    for_each = var.waf_configuration != null ? [var.waf_configuration] : []
    content {
      enabled                  = waf_configuration.value.enabled
      firewall_mode            = waf_configuration.value.firewall_mode
      rule_set_version         = waf_configuration.value.rule_set_version
      rule_set_type            = waf_configuration.value.rule_set_type
      file_upload_limit_mb     = waf_configuration.value.file_upload_limit_mb
      max_request_body_size_kb = waf_configuration.value.max_request_body_size_kb
      request_body_check       = waf_configuration.value.request_body_check

      dynamic "disabled_rule_group" {
        for_each = coalesce(waf_configuration.value.disabled_rule_groups, [])
        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = disabled_rule_group.value.rules
        }
      }

      dynamic "exclusion" {
        for_each = coalesce(waf_configuration.value.exclusions, [])
        content {
          match_variable          = exclusion.value.match_variable
          selector                = exclusion.value.selector
          selector_match_operator = exclusion.value.selector_match_operator
        }
      }
    }
  }

  dynamic "global" {
    for_each = var.global != null ? [var.global] : []
    content {
      request_buffering_enabled  = global.value.request_buffering_enabled
      response_buffering_enabled = global.value.response_buffering_enabled
    }
  }

  dynamic "timeouts" {
    for_each = length(keys(var.timeouts)) > 0 ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
