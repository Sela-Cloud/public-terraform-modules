variable "app_service" {
  description = "Map of Azure App Service configurations to create."

  type = map(object({
    # Mandatory attributes (No default values)
    name                = string
    resource_group_name = string
    location            = string

    # Optional Hosting & Service Plan attributes (With default values)
    os_type                = optional(string, "Linux")
    create_service_plan    = optional(bool, true)
    service_plan_name      = optional(string)
    service_plan_sku       = optional(string, "B1")
    service_plan_id        = optional(string)
    zone_balancing_enabled = optional(bool, false)

    # Optional Security & Networking attributes (With default values)
    https_only                    = optional(bool, true)
    client_affinity_enabled       = optional(bool, false)
    client_certificate_enabled    = optional(bool, false)
    client_certificate_mode       = optional(string)
    public_network_access_enabled = optional(bool, true)
    virtual_network_subnet_id     = optional(string)
    identity_type                 = optional(string, "SystemAssigned")
    identity_ids                  = optional(list(string), [])
    app_settings                  = optional(map(string), {})

    # Optional Site Configuration attributes (With default values)
    site_config = optional(object({
      always_on                         = optional(bool, true)
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
    }), {})

    connection_strings = optional(list(object({
      name  = string
      type  = string
      value = string
    })), [])

    storage_mounts = optional(list(object({
      name         = string
      type         = string
      account_name = string
      share_name   = string
      access_key   = string
      mount_path   = string
    })), [])

    tags = optional(map(string), {})
  }))

  default = {}
}
