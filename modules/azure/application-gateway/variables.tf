variable "name" {
  description = "(Required) The name of the Application Gateway. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Application Gateway. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure region where the Application Gateway should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "sku" {
  description = "(Required) The SKU of the Application Gateway."
  type = object({
    name     = string
    tier     = string
    capacity = optional(number, null)
  })
  default = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = null
  }
}

variable "autoscale_configuration" {
  description = "(Optional) Autoscale configuration for the Application Gateway. Required for v2 SKUs unless static capacity is specified in sku."
  type = object({
    min_capacity = number
    max_capacity = optional(number, null)
  })
  default = {
    min_capacity = 1
    max_capacity = 10
  }
}

variable "gateway_ip_configurations" {
  description = "(Required) One or two gateway_ip_configuration blocks defining the subnet(s) for the Application Gateway."
  type = list(object({
    name      = string
    subnet_id = string
  }))
}

variable "frontend_ip_configurations" {
  description = "(Required) One or more frontend_ip_configuration blocks."
  type = list(object({
    name                            = string
    subnet_id                       = optional(string, null)
    private_ip_address              = optional(string, null)
    private_ip_address_allocation   = optional(string, null)
    public_ip_address_id            = optional(string, null)
    private_link_configuration_name = optional(string, null)
  }))
}

variable "frontend_ports" {
  description = "(Required) One or more frontend_port blocks."
  type = list(object({
    name = string
    port = number
  }))
}

variable "backend_address_pools" {
  description = "(Required) One or more backend_address_pool blocks."
  type = list(object({
    name         = string
    fqdns        = optional(list(string), null)
    ip_addresses = optional(list(string), null)
  }))
}

variable "backend_http_settings" {
  description = "(Required) One or more backend_http_settings blocks."
  type = list(object({
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
}

variable "http_listeners" {
  description = "(Required) One or more http_listener blocks."
  type = list(object({
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
}

variable "request_routing_rules" {
  description = "(Required) One or more request_routing_rule blocks."
  type = list(object({
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
}

variable "probes" {
  description = "(Optional) One or more probe blocks for custom health checking."
  type = list(object({
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
  }))
  default = []
}

variable "identity" {
  description = "(Optional) Managed Service Identity block for accessing Key Vault certificates."
  type = object({
    type         = string
    identity_ids = optional(list(string), null)
  })
  default = null
}

variable "ssl_certificates" {
  description = "(Optional) One or more ssl_certificate blocks."
  type = list(object({
    name                = string
    data                = optional(string, null)
    password            = optional(string, null)
    key_vault_secret_id = optional(string, null)
  }))
  default = []
}

variable "ssl_policy" {
  description = "(Optional) Global SSL policy block."
  type = object({
    policy_type          = optional(string, null)
    policy_name          = optional(string, null)
    min_protocol_version = optional(string, null)
    cipher_suites        = optional(list(string), null)
    disabled_protocols   = optional(list(string), null)
  })
  default = null
}

variable "trusted_root_certificates" {
  description = "(Optional) One or more trusted_root_certificate blocks."
  type = list(object({
    name                = string
    data                = optional(string, null)
    key_vault_secret_id = optional(string, null)
  }))
  default = []
}

variable "redirect_configurations" {
  description = "(Optional) One or more redirect_configuration blocks."
  type = list(object({
    name                 = string
    redirect_type        = string
    target_listener_name = optional(string, null)
    target_url           = optional(string, null)
    include_path         = optional(bool, false)
    include_query_string = optional(bool, false)
  }))
  default = []
}

variable "url_path_maps" {
  description = "(Optional) One or more url_path_map blocks."
  type = list(object({
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
  }))
  default = []
}

variable "rewrite_rule_sets" {
  description = "(Optional) One or more rewrite_rule_set blocks."
  type = list(object({
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
  }))
  default = []
}

variable "waf_configuration" {
  description = "(Optional) Web Application Firewall (WAF) configuration block."
  type = object({
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
  })
  default = null
}

variable "zones" {
  description = "(Optional) A list of Availability Zones in which this Application Gateway should be deployed."
  type        = list(string)
  default     = null
}

variable "http2_enabled" {
  description = "(Optional) Is HTTP2 enabled on the application gateway? Defaults to true."
  type        = bool
  default     = true
}

variable "fips_enabled" {
  description = "(Optional) Is FIPS enabled on the application gateway? Defaults to null."
  type        = bool
  default     = null
}

variable "firewall_policy_id" {
  description = "(Optional) The ID of the Web Application Firewall Policy."
  type        = string
  default     = null
}

variable "force_firewall_policy_association" {
  description = "(Optional) Is the Firewall Policy associated with the Application Gateway forced? Defaults to false."
  type        = bool
  default     = null
}

variable "global" {
  description = "(Optional) Global configuration for Application Gateway."
  type = object({
    request_buffering_enabled  = bool
    response_buffering_enabled = bool
  })
  default = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
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
