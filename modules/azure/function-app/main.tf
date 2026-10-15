locals {
  service_plan_id = var.service_plan_id != null ? var.service_plan_id : (
    var.create_service_plan ? azurerm_service_plan.plan[0].id : null
  )
  service_plan_name = var.service_plan_name != null ? var.service_plan_name : "asp-${var.name}"

  # Azure forbids always_on = true on Consumption (Y1) SKU
  is_consumption = lower(var.service_plan_sku) == "y1"
  always_on      = local.is_consumption ? false : coalesce(var.site_config.always_on, false)

  # Auto-generate sanitized storage account name (3-24 lowercase alphanumerics) if not explicitly provided
  clean_app_name               = lower(replace(var.name, "/[^a-zA-Z0-9]/", ""))
  default_storage_account_name = substr("stfn${local.clean_app_name}", 0, 24)

  storage_account_name = var.storage_account_name != null ? var.storage_account_name : (
    length(azurerm_storage_account.storage) > 0 ? azurerm_storage_account.storage[0].name : null
  )
  storage_account_access_key = var.storage_account_access_key != null ? var.storage_account_access_key : (
    length(azurerm_storage_account.storage) > 0 ? azurerm_storage_account.storage[0].primary_access_key : null
  )
}

resource "azurerm_storage_account" "storage" {
  count = var.create_storage_account && var.storage_account_access_key == null ? 1 : 0

  name                     = var.storage_account_name != null ? var.storage_account_name : local.default_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_service_plan" "plan" {
  count = var.service_plan_id == null && var.create_service_plan ? 1 : 0

  name                   = local.service_plan_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  os_type                = var.os_type
  sku_name               = var.service_plan_sku
  zone_balancing_enabled = var.zone_balancing_enabled
  tags                   = var.tags
}

resource "azurerm_linux_function_app" "linux_function_app" {
  count = var.os_type == "Linux" ? 1 : 0

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = local.service_plan_id
  storage_account_name          = local.storage_account_name
  storage_account_access_key    = local.storage_account_access_key
  storage_uses_managed_identity = var.storage_uses_managed_identity
  https_only                    = var.https_only
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  builtin_logging_enabled       = var.builtin_logging_enabled
  functions_extension_version   = var.functions_extension_version
  app_settings                  = var.app_settings
  tags                          = var.tags

  site_config {
    always_on                = local.always_on
    ftps_state               = coalesce(var.site_config.ftps_state, "FtpsOnly")
    minimum_tls_version      = coalesce(var.site_config.minimum_tls_version, "1.2")
    http2_enabled            = coalesce(var.site_config.http2_enabled, false)
    app_scale_limit          = var.site_config.app_scale_limit
    elastic_instance_minimum = var.site_config.elastic_instance_minimum

    dynamic "application_stack" {
      for_each = var.site_config.application_stack != null ? [var.site_config.application_stack] : []
      content {
        dotnet_version              = application_stack.value.dotnet_version
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime
        node_version                = application_stack.value.node_version
        python_version              = application_stack.value.python_version
        java_version                = application_stack.value.java_version
        powershell_core_version     = application_stack.value.powershell_core_version
        use_custom_runtime          = application_stack.value.use_custom_runtime

        dynamic "docker" {
          for_each = application_stack.value.docker != null ? [application_stack.value.docker] : []
          content {
            image_name        = docker.value.image_name
            image_tag         = docker.value.image_tag
            registry_url      = docker.value.registry_url
            registry_username = docker.value.registry_username
            registry_password = docker.value.registry_password
          }
        }
      }
    }

    dynamic "cors" {
      for_each = var.site_config.cors != null ? [var.site_config.cors] : []
      content {
        allowed_origins     = coalesce(cors.value.allowed_origins, [])
        support_credentials = coalesce(cors.value.support_credentials, false)
      }
    }

    dynamic "ip_restriction" {
      for_each = coalesce(var.site_config.ip_restriction, [])
      content {
        name                      = ip_restriction.value.name
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        priority                  = coalesce(ip_restriction.value.priority, 100)
        action                    = coalesce(ip_restriction.value.action, "Allow")
        description               = ip_restriction.value.description
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = coalesce(var.site_config.scm_ip_restriction, [])
      content {
        name                      = scm_ip_restriction.value.name
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        priority                  = coalesce(scm_ip_restriction.value.priority, 100)
        action                    = coalesce(scm_ip_restriction.value.action, "Allow")
        description               = scm_ip_restriction.value.description
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }
}

resource "azurerm_windows_function_app" "windows_function_app" {
  count = var.os_type == "Windows" ? 1 : 0

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = local.service_plan_id
  storage_account_name          = local.storage_account_name
  storage_account_access_key    = local.storage_account_access_key
  storage_uses_managed_identity = var.storage_uses_managed_identity
  https_only                    = var.https_only
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  builtin_logging_enabled       = var.builtin_logging_enabled
  functions_extension_version   = var.functions_extension_version
  app_settings                  = var.app_settings
  tags                          = var.tags

  site_config {
    always_on                = local.always_on
    ftps_state               = coalesce(var.site_config.ftps_state, "FtpsOnly")
    minimum_tls_version      = coalesce(var.site_config.minimum_tls_version, "1.2")
    http2_enabled            = coalesce(var.site_config.http2_enabled, false)
    app_scale_limit          = var.site_config.app_scale_limit
    elastic_instance_minimum = var.site_config.elastic_instance_minimum

    dynamic "application_stack" {
      for_each = var.site_config.application_stack != null ? [var.site_config.application_stack] : []
      content {
        dotnet_version              = application_stack.value.dotnet_version
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime
        java_version                = application_stack.value.java_version
        node_version                = application_stack.value.node_version
        powershell_core_version     = application_stack.value.powershell_core_version
        use_custom_runtime          = application_stack.value.use_custom_runtime
      }
    }

    dynamic "cors" {
      for_each = var.site_config.cors != null ? [var.site_config.cors] : []
      content {
        allowed_origins     = coalesce(cors.value.allowed_origins, [])
        support_credentials = coalesce(cors.value.support_credentials, false)
      }
    }

    dynamic "ip_restriction" {
      for_each = coalesce(var.site_config.ip_restriction, [])
      content {
        name                      = ip_restriction.value.name
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        priority                  = coalesce(ip_restriction.value.priority, 100)
        action                    = coalesce(ip_restriction.value.action, "Allow")
        description               = ip_restriction.value.description
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = coalesce(var.site_config.scm_ip_restriction, [])
      content {
        name                      = scm_ip_restriction.value.name
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        priority                  = coalesce(scm_ip_restriction.value.priority, 100)
        action                    = coalesce(scm_ip_restriction.value.action, "Allow")
        description               = scm_ip_restriction.value.description
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }
}
