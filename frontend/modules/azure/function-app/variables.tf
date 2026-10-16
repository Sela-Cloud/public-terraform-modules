variable "function_app" {
  description = "Map of Azure Function App configurations to create."

  type = map(object({
    # Mandatory attributes (No default values)
    name                = string
    resource_group_name = string
    location            = string

    # Optional Resource Group attributes
    create_resource_group = optional(bool, false)

    # Optional Hosting & Service Plan attributes (With default values)
    os_type                = optional(string, "Linux")
    create_service_plan    = optional(bool, true)
    service_plan_name      = optional(string)
    service_plan_sku       = optional(string, "Y1")
    service_plan_id        = optional(string)
    zone_balancing_enabled = optional(bool, false)

    # Optional Backend Storage attributes
    create_storage_account           = optional(bool, true)
    storage_account_name             = optional(string)
    storage_account_access_key       = optional(string)
    storage_uses_managed_identity    = optional(bool, false)
    storage_account_tier             = optional(string, "Standard")
    storage_account_replication_type = optional(string, "LRS")

    # Optional Security & Networking attributes (With default values)
    https_only                    = optional(bool, true)
    client_certificate_enabled    = optional(bool, false)
    client_certificate_mode       = optional(string)
    public_network_access_enabled = optional(bool, true)
    virtual_network_subnet_id     = optional(string)
    builtin_logging_enabled       = optional(bool, true)
    functions_extension_version   = optional(string, "~4")
    identity_type                 = optional(string, "SystemAssigned")
    identity_ids                  = optional(list(string), [])
    app_settings                  = optional(map(string), {})

    # Optional Site Configuration attributes
    site_config = optional(object({
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
    }), {})

    connection_strings = optional(list(object({
      name  = string
      type  = string
      value = string
    })), [])

    tags = optional(map(string), {})
  }))

  default = {}
}
