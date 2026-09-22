variable "virtual_machine_scale_set" {
  description = "Map of Azure Virtual Machine Scale Set configurations to create."
  type = map(object({
    name                = optional(string, "vmss-default")
    resource_group_name = optional(string, "rg-default")
    location            = optional(string, "eastus")
    sku = optional(object({
      name     = optional(string, "Standard_B2s")
      tier     = optional(string, "Standard")
      capacity = optional(number, 2)
      }), {
      name     = "Standard_B2s"
      tier     = "Standard"
      capacity = 2
    })
    upgrade_policy_mode  = optional(string, "Manual")
    automatic_os_upgrade = optional(bool, false)
    health_probe_id      = optional(string, null)
    rolling_upgrade_policy = optional(object({
      max_batch_instance_percent              = optional(number, 20)
      max_unhealthy_instance_percent          = optional(number, 20)
      max_unhealthy_upgraded_instance_percent = optional(number, 20)
      pause_time_between_batches              = optional(string, "PT0S")
    }), null)
    overprovision                = optional(bool, true)
    single_placement_group       = optional(bool, true)
    priority                     = optional(string, "Regular")
    eviction_policy              = optional(string, null)
    zones                        = optional(list(string), null)
    proximity_placement_group_id = optional(string, null)
    license_type                 = optional(string, null)
    storage_profile_os_disk = optional(object({
      name              = optional(string, null)
      caching           = optional(string, "ReadWrite")
      create_option     = optional(string, "FromImage")
      managed_disk_type = optional(string, "Standard_LRS")
      os_type           = optional(string, null)
      image             = optional(string, null)
      vhd_containers    = optional(list(string), null)
      }), {
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
    })
    storage_profile_image_reference = optional(object({
      publisher = optional(string, "Canonical")
      offer     = optional(string, "0001-com-ubuntu-server-jammy")
      sku       = optional(string, "22_04-lts")
      version   = optional(string, "latest")
      id        = optional(string, null)
      }), {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts"
      version   = "latest"
    })
    storage_profile_data_disks = optional(list(object({
      lun               = number
      caching           = optional(string, "ReadWrite")
      create_option     = optional(string, "Empty")
      disk_size_gb      = optional(number, 30)
      managed_disk_type = optional(string, "Standard_LRS")
    })), [])
    os_profile = optional(object({
      computer_name_prefix = optional(string, "vmss")
      admin_username       = optional(string, "azureuser")
      admin_password       = optional(string, null)
      custom_data          = optional(string, null)
      }), {
      computer_name_prefix = "vmss"
      admin_username       = "azureuser"
    })
    os_profile_linux_config = optional(object({
      disable_password_authentication = optional(bool, false)
      ssh_keys = optional(list(object({
        path     = string
        key_data = optional(string, null)
      })), [])
    }), null)
    os_profile_windows_config = optional(object({
      provision_vm_agent        = optional(bool, true)
      enable_automatic_upgrades = optional(bool, false)
    }), null)
    network_profiles = list(object({
      name                      = string
      primary                   = bool
      accelerated_networking    = optional(bool, false)
      ip_forwarding             = optional(bool, false)
      network_security_group_id = optional(string, null)
      dns_servers               = optional(list(string), [])
      ip_configurations = list(object({
        name                                         = string
        primary                                      = bool
        subnet_id                                    = string
        application_gateway_backend_address_pool_ids = optional(list(string), [])
        load_balancer_backend_address_pool_ids       = optional(list(string), [])
        load_balancer_inbound_nat_rules_ids          = optional(list(string), [])
        application_security_group_ids               = optional(list(string), [])
        public_ip_address_configuration = optional(object({
          name              = string
          idle_timeout      = number
          domain_name_label = string
        }), null)
      }))
    }))
    identity = optional(object({
      type         = optional(string, "SystemAssigned")
      identity_ids = optional(list(string), [])
    }), null)
    boot_diagnostics = optional(object({
      enabled     = optional(bool, true)
      storage_uri = string
    }), null)
    extensions = optional(list(object({
      name                       = string
      publisher                  = string
      type                       = string
      type_handler_version       = string
      auto_upgrade_minor_version = optional(bool, true)
      provision_after_extensions = optional(list(string), [])
      settings                   = optional(string, null)
      protected_settings         = optional(string, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
