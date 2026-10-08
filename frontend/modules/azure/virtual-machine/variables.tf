variable "virtual_machine" {
  description = "Map of Azure Virtual Machine configurations to create."

  type = map(object({
    name                  = string
    resource_group_name   = string
    location              = string
    network_interface_ids = list(string)

    vm_size                      = optional(string, "Standard_B2s")
    primary_network_interface_id = optional(string)
    availability_set_id          = optional(string)
    zones                        = optional(list(string))
    proximity_placement_group_id = optional(string)
    license_type                 = optional(string)

    delete_os_disk_on_termination    = optional(bool, true)
    delete_data_disks_on_termination = optional(bool, false)

    storage_os_disk = optional(object({
      name                      = optional(string)
      caching                   = optional(string, "ReadWrite")
      create_option             = optional(string, "FromImage")
      managed_disk_type         = optional(string, "Standard_LRS")
      disk_size_gb              = optional(number)
      os_type                   = optional(string)
      managed_disk_id           = optional(string)
      image_uri                 = optional(string)
      vhd_uri                   = optional(string)
      write_accelerator_enabled = optional(bool, false)
    }))

    storage_image_reference = optional(object({
      publisher = optional(string, "Canonical")
      offer     = optional(string, "0001-com-ubuntu-server-jammy")
      sku       = optional(string, "22_04-lts")
      version   = optional(string, "latest")
      id        = optional(string)
    }))

    storage_data_disks = optional(list(object({
      name                      = string
      caching                   = optional(string, "None")
      create_option             = optional(string, "Empty")
      disk_size_gb              = number
      lun                       = number
      managed_disk_type         = optional(string, "Standard_LRS")
      managed_disk_id           = optional(string)
      vhd_uri                   = optional(string)
      write_accelerator_enabled = optional(bool, false)
    })), [])

    os_profile = optional(object({
      computer_name  = optional(string)
      admin_username = optional(string, "azureuser")
      admin_password = optional(string)
      custom_data    = optional(string)
    }))

    os_profile_linux_config = optional(object({
      disable_password_authentication = optional(bool, false)
      ssh_keys = optional(list(object({
        path     = string
        key_data = string
      })), [])
    }))

    os_profile_windows_config = optional(object({
      provision_vm_agent        = optional(bool, true)
      enable_automatic_upgrades = optional(bool, true)
      timezone                  = optional(string)
    }))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    boot_diagnostics = optional(object({
      enabled     = bool
      storage_uri = optional(string)
    }))

    tags = optional(map(string), {})
  }))

  default = {}
}
