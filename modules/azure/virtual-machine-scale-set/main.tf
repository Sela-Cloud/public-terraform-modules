resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  upgrade_policy_mode          = var.upgrade_policy_mode
  automatic_os_upgrade         = var.automatic_os_upgrade
  health_probe_id              = var.health_probe_id
  overprovision                = var.overprovision
  single_placement_group       = var.single_placement_group
  priority                     = var.priority
  eviction_policy              = var.priority == "Low" ? var.eviction_policy : null
  zones                        = var.zones
  proximity_placement_group_id = var.proximity_placement_group_id
  license_type                 = var.license_type
  tags                         = var.tags

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.sku.capacity
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.rolling_upgrade_policy != null && var.upgrade_policy_mode == "Rolling" ? [var.rolling_upgrade_policy] : []
    content {
      max_batch_instance_percent              = rolling_upgrade_policy.value.max_batch_instance_percent
      max_unhealthy_instance_percent          = rolling_upgrade_policy.value.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = rolling_upgrade_policy.value.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = rolling_upgrade_policy.value.pause_time_between_batches
    }
  }

  storage_profile_os_disk {
    name              = var.storage_profile_os_disk.name
    caching           = var.storage_profile_os_disk.caching
    create_option     = var.storage_profile_os_disk.create_option
    managed_disk_type = var.storage_profile_os_disk.managed_disk_type
    os_type           = var.storage_profile_os_disk.os_type
    image             = var.storage_profile_os_disk.image
    vhd_containers    = var.storage_profile_os_disk.vhd_containers
  }

  dynamic "storage_profile_image_reference" {
    for_each = var.storage_profile_image_reference != null ? [var.storage_profile_image_reference] : []
    content {
      publisher = storage_profile_image_reference.value.publisher
      offer     = storage_profile_image_reference.value.offer
      sku       = storage_profile_image_reference.value.sku
      version   = storage_profile_image_reference.value.version
      id        = storage_profile_image_reference.value.id
    }
  }

  dynamic "storage_profile_data_disk" {
    for_each = var.storage_profile_data_disks
    content {
      lun               = storage_profile_data_disk.value.lun
      caching           = storage_profile_data_disk.value.caching
      create_option     = storage_profile_data_disk.value.create_option
      disk_size_gb      = storage_profile_data_disk.value.disk_size_gb
      managed_disk_type = storage_profile_data_disk.value.managed_disk_type
    }
  }

  os_profile {
    computer_name_prefix = var.os_profile.computer_name_prefix
    admin_username       = var.os_profile.admin_username
    admin_password       = var.os_profile.admin_password
    custom_data          = var.os_profile.custom_data
  }

  dynamic "os_profile_linux_config" {
    for_each = var.os_profile_linux_config != null ? [var.os_profile_linux_config] : []
    content {
      disable_password_authentication = os_profile_linux_config.value.disable_password_authentication

      dynamic "ssh_keys" {
        for_each = os_profile_linux_config.value.ssh_keys != null ? os_profile_linux_config.value.ssh_keys : []
        content {
          path     = ssh_keys.value.path
          key_data = ssh_keys.value.key_data
        }
      }
    }
  }

  dynamic "os_profile_windows_config" {
    for_each = var.os_profile_windows_config != null ? [var.os_profile_windows_config] : []
    content {
      provision_vm_agent        = os_profile_windows_config.value.provision_vm_agent
      enable_automatic_upgrades = os_profile_windows_config.value.enable_automatic_upgrades
    }
  }

  dynamic "network_profile" {
    for_each = var.network_profiles
    content {
      name                      = network_profile.value.name
      primary                   = network_profile.value.primary
      accelerated_networking    = network_profile.value.accelerated_networking
      ip_forwarding             = network_profile.value.ip_forwarding
      network_security_group_id = network_profile.value.network_security_group_id

      dynamic "dns_settings" {
        for_each = length(network_profile.value.dns_servers) > 0 ? [network_profile.value.dns_servers] : []
        content {
          dns_servers = dns_settings.value
        }
      }

      dynamic "ip_configuration" {
        for_each = network_profile.value.ip_configurations
        content {
          name                                         = ip_configuration.value.name
          primary                                      = ip_configuration.value.primary
          subnet_id                                    = ip_configuration.value.subnet_id
          application_gateway_backend_address_pool_ids = ip_configuration.value.application_gateway_backend_address_pool_ids
          load_balancer_backend_address_pool_ids       = ip_configuration.value.load_balancer_backend_address_pool_ids
          load_balancer_inbound_nat_rules_ids          = ip_configuration.value.load_balancer_inbound_nat_rules_ids
          application_security_group_ids               = ip_configuration.value.application_security_group_ids

          dynamic "public_ip_address_configuration" {
            for_each = ip_configuration.value.public_ip_address_configuration != null ? [ip_configuration.value.public_ip_address_configuration] : []
            content {
              name              = public_ip_address_configuration.value.name
              idle_timeout      = public_ip_address_configuration.value.idle_timeout
              domain_name_label = public_ip_address_configuration.value.domain_name_label
            }
          }
        }
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.type == "UserAssigned" || identity.value.type == "SystemAssigned, UserAssigned" ? identity.value.identity_ids : null
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics != null ? [var.boot_diagnostics] : []
    content {
      enabled     = boot_diagnostics.value.enabled
      storage_uri = boot_diagnostics.value.storage_uri
    }
  }

  dynamic "extension" {
    for_each = var.extensions
    content {
      name                       = extension.value.name
      publisher                  = extension.value.publisher
      type                       = extension.value.type
      type_handler_version       = extension.value.type_handler_version
      auto_upgrade_minor_version = extension.value.auto_upgrade_minor_version
      provision_after_extensions = extension.value.provision_after_extensions
      settings                   = extension.value.settings
      protected_settings         = extension.value.protected_settings
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
