variable "name" {
  description = "Specifies the name of the Virtual Machine. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 64
    error_message = "Virtual Machine name must be between 1 and 64 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "Specifies the name of the Resource Group in which the Virtual Machine should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "Specifies the Azure Region where the Virtual Machine exists. Changing this forces a new resource to be created."
  type        = string
}

variable "network_interface_ids" {
  description = "Specifies the list of Network Interface IDs associated with this Virtual Machine."
  type        = list(string)
}

variable "vm_size" {
  description = "Specifies the size of the Virtual Machine. Defaults to 'Standard_B2s'."
  type        = string
  default     = "Standard_B2s"
}

variable "primary_network_interface_id" {
  description = "The ID of the Network Interface (in the network_interface_ids list) that should be the primary network interface on this Virtual Machine."
  type        = string
  default     = null
}

variable "availability_set_id" {
  description = "The ID of the Availability Set in which the Virtual Machine should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "zones" {
  description = "A list of a single item of the Availability Zone which the Virtual Machine should be allocated in."
  type        = list(string)
  default     = null
}

variable "proximity_placement_group_id" {
  description = "The ID of the Proximity Placement Group the Virtual Machine should belong to."
  type        = string
  default     = null
}

variable "license_type" {
  description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable for DOS (Windows Server) images. Possible values are 'Windows_Client' and 'Windows_Server'."
  type        = string
  default     = null
}

variable "delete_os_disk_on_termination" {
  description = "Should the OS Disk (either the Managed Disk or VHD Blob) be deleted when the Virtual Machine is destroyed? Defaults to true."
  type        = bool
  default     = true
}

variable "delete_data_disks_on_termination" {
  description = "Should the Data Disks (either the Managed Disks or VHD Blobs) be deleted when the Virtual Machine is destroyed? Defaults to false."
  type        = bool
  default     = false
}

variable "storage_os_disk" {
  description = "Configuration for the OS Disk. If name is not specified, defaults to '<name>-osdisk'."
  type = object({
    name                      = optional(string, null)
    caching                   = optional(string, "ReadWrite")
    create_option             = optional(string, "FromImage")
    managed_disk_type         = optional(string, "Standard_LRS")
    disk_size_gb              = optional(number, null)
    os_type                   = optional(string, null)
    managed_disk_id           = optional(string, null)
    image_uri                 = optional(string, null)
    vhd_uri                   = optional(string, null)
    write_accelerator_enabled = optional(bool, false)
  })
  default = {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

variable "storage_image_reference" {
  description = "Image reference configuration. Defaults to Ubuntu 22.04 LTS."
  type = object({
    publisher = optional(string, "Canonical")
    offer     = optional(string, "0001-com-ubuntu-server-jammy")
    sku       = optional(string, "22_04-lts")
    version   = optional(string, "latest")
    id        = optional(string, null)
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

variable "storage_data_disks" {
  description = "List of storage data disks to attach to the Virtual Machine."
  type = list(object({
    name                      = string
    caching                   = optional(string, "None")
    create_option             = optional(string, "Empty")
    disk_size_gb              = number
    lun                       = number
    managed_disk_type         = optional(string, "Standard_LRS")
    managed_disk_id           = optional(string, null)
    vhd_uri                   = optional(string, null)
    write_accelerator_enabled = optional(bool, false)
  }))
  default = []
}

variable "os_profile" {
  description = "Specifies the operating system settings for the Virtual Machine. Required when create_option is FromImage."
  type = object({
    computer_name  = optional(string, null)
    admin_username = optional(string, "azureuser")
    admin_password = optional(string, null)
    custom_data    = optional(string, null)
  })
  default = null
}

variable "os_profile_linux_config" {
  description = "Specifies the Linux operating system settings on the Virtual Machine."
  type = object({
    disable_password_authentication = optional(bool, false)
    ssh_keys = optional(list(object({
      path     = string
      key_data = string
    })), [])
  })
  default = null
}

variable "os_profile_windows_config" {
  description = "Specifies the Windows operating system settings on the Virtual Machine."
  type = object({
    provision_vm_agent        = optional(bool, true)
    enable_automatic_upgrades = optional(bool, true)
    timezone                  = optional(string, null)
  })
  default = null
}

variable "identity" {
  description = "Specifies the Managed Service Identity configuration for the Virtual Machine."
  type = object({
    type         = string
    identity_ids = optional(list(string), null)
  })
  default = null
}

variable "boot_diagnostics" {
  description = "Specifies the Boot Diagnostics configuration for the Virtual Machine."
  type = object({
    enabled     = bool
    storage_uri = optional(string, null)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Virtual Machine."
  type        = map(string)
  default     = {}
}
