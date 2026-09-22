resource "azurerm_virtual_machine" "vm" {
  name                             = var.name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  vm_size                          = var.vm_size
  network_interface_ids            = var.network_interface_ids
  primary_network_interface_id     = var.primary_network_interface_id
  availability_set_id              = var.availability_set_id
  zones                            = var.zones
  proximity_placement_group_id     = var.proximity_placement_group_id
  license_type                     = var.license_type
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  tags                             = var.tags

  storage_os_disk {
    name                      = coalesce(var.storage_os_disk.name, "${var.name}-osdisk")
    caching                   = coalesce(var.storage_os_disk.caching, "ReadWrite")
    create_option             = coalesce(var.storage_os_disk.create_option, "FromImage")
    managed_disk_type         = coalesce(var.storage_os_disk.managed_disk_type, "Standard_LRS")
    disk_size_gb              = var.storage_os_disk.disk_size_gb
    os_type                   = var.storage_os_disk.os_type
    managed_disk_id           = var.storage_os_disk.managed_disk_id
    image_uri                 = var.storage_os_disk.image_uri
    vhd_uri                   = var.storage_os_disk.vhd_uri
    write_accelerator_enabled = var.storage_os_disk.write_accelerator_enabled
  }

  dynamic "storage_image_reference" {
    for_each = var.storage_image_reference != null ? [var.storage_image_reference] : []
    content {
      id        = storage_image_reference.value.id
      publisher = storage_image_reference.value.publisher
      offer     = storage_image_reference.value.offer
      sku       = storage_image_reference.value.sku
      version   = storage_image_reference.value.version
    }
  }

  dynamic "storage_data_disk" {
    for_each = var.storage_data_disks
    content {
      name                      = storage_data_disk.value.name
      caching                   = coalesce(storage_data_disk.value.caching, "None")
      create_option             = coalesce(storage_data_disk.value.create_option, "Empty")
      disk_size_gb              = storage_data_disk.value.disk_size_gb
      lun                       = storage_data_disk.value.lun
      managed_disk_type         = storage_data_disk.value.managed_disk_type
      managed_disk_id           = storage_data_disk.value.managed_disk_id
      vhd_uri                   = storage_data_disk.value.vhd_uri
      write_accelerator_enabled = storage_data_disk.value.write_accelerator_enabled
    }
  }

  dynamic "os_profile" {
    for_each = var.os_profile != null ? [var.os_profile] : []
    content {
      computer_name  = coalesce(os_profile.value.computer_name, var.name)
      admin_username = coalesce(os_profile.value.admin_username, "azureuser")
      admin_password = os_profile.value.admin_password
      custom_data    = os_profile.value.custom_data
    }
  }

  dynamic "os_profile_linux_config" {
    for_each = var.os_profile_linux_config != null ? [var.os_profile_linux_config] : []
    content {
      disable_password_authentication = coalesce(os_profile_linux_config.value.disable_password_authentication, false)

      dynamic "ssh_keys" {
        for_each = coalesce(os_profile_linux_config.value.ssh_keys, [])
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
      provision_vm_agent        = coalesce(os_profile_windows_config.value.provision_vm_agent, true)
      enable_automatic_upgrades = coalesce(os_profile_windows_config.value.enable_automatic_upgrades, true)
      timezone                  = os_profile_windows_config.value.timezone
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics != null ? [var.boot_diagnostics] : []
    content {
      enabled     = boot_diagnostics.value.enabled
      storage_uri = boot_diagnostics.value.storage_uri
    }
  }
}
