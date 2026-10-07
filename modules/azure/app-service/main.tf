locals {
  service_plan_id = var.service_plan_id != null ? var.service_plan_id : (
    var.create_service_plan ? azurerm_service_plan.plan[0].id : null
  )
  service_plan_name = var.service_plan_name != null ? var.service_plan_name : "asp-${var.name}"
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

resource "azurerm_linux_web_app" "linux_app" {
  count = var.os_type == "Linux" ? 1 : 0

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = local.service_plan_id
  https_only                    = var.https_only
  client_affinity_enabled       = var.client_affinity_enabled
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  app_settings                  = var.app_settings
  tags                          = var.tags

  site_config {
    always_on                         = coalesce(var.site_config.always_on, true)
    ftps_state                        = coalesce(var.site_config.ftps_state, "FtpsOnly")
    minimum_tls_version               = coalesce(var.site_config.minimum_tls_version, "1.2")
    http2_enabled                     = coalesce(var.site_config.http2_enabled, false)
    health_check_path                 = var.site_config.health_check_path
    health_check_eviction_time_in_min = var.site_config.health_check_eviction_time_in_min

    dynamic "application_stack" {
      for_each = var.site_config.application_stack != null ? [var.site_config.application_stack] : []
      content {
        dotnet_version      = application_stack.value.dotnet_version
        node_version        = application_stack.value.node_version
        python_version      = application_stack.value.python_version
        java_version        = application_stack.value.java_version
        php_version         = application_stack.value.php_version
        docker_image_name   = application_stack.value.docker_image_name
        docker_registry_url = application_stack.value.docker_registry_url
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

  dynamic "storage_account" {
    for_each = var.storage_mounts
    content {
      name         = storage_account.value.name
      type         = storage_account.value.type
      account_name = storage_account.value.account_name
      share_name   = storage_account.value.share_name
      access_key   = storage_account.value.access_key
      mount_path   = storage_account.value.mount_path
    }
  }
}

resource "azurerm_windows_web_app" "windows_app" {
  count = var.os_type == "Windows" ? 1 : 0

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = local.service_plan_id
  https_only                    = var.https_only
  client_affinity_enabled       = var.client_affinity_enabled
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  app_settings                  = var.app_settings
  tags                          = var.tags

  site_config {
    always_on                         = coalesce(var.site_config.always_on, true)
    ftps_state                        = coalesce(var.site_config.ftps_state, "FtpsOnly")
    minimum_tls_version               = coalesce(var.site_config.minimum_tls_version, "1.2")
    http2_enabled                     = coalesce(var.site_config.http2_enabled, false)
    health_check_path                 = var.site_config.health_check_path
    health_check_eviction_time_in_min = var.site_config.health_check_eviction_time_in_min

    dynamic "application_stack" {
      for_each = var.site_config.application_stack != null ? [var.site_config.application_stack] : []
      content {
        dotnet_version      = application_stack.value.dotnet_version
        node_version        = application_stack.value.node_version
        java_version        = application_stack.value.java_version
        php_version         = application_stack.value.php_version
        docker_image_name   = application_stack.value.docker_image_name
        docker_registry_url = application_stack.value.docker_registry_url
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

  dynamic "storage_account" {
    for_each = var.storage_mounts
    content {
      name         = storage_account.value.name
      type         = storage_account.value.type
      account_name = storage_account.value.account_name
      share_name   = storage_account.value.share_name
      access_key   = storage_account.value.access_key
      mount_path   = storage_account.value.mount_path
    }
  }
}
