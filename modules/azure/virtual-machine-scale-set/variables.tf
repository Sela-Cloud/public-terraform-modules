variable "name" {
  description = "Specifies the name of the Virtual Machine Scale Set resource. Changing this forces a new resource to be created."
  type        = string
  default     = "vmss-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 64
    error_message = "Virtual Machine Scale Set name must be between 1 and 64 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only letters, numbers, underscores, periods, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the Virtual Machine Scale Set. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "sku" {
  description = "The Virtual Machine Scale Set SKU and capacity configuration."
  type = object({
    name     = optional(string, "Standard_B2s")
    tier     = optional(string, "Standard")
    capacity = optional(number, 2)
  })
  default = {
    name     = "Standard_B2s"
    tier     = "Standard"
    capacity = 2
  }
}

variable "upgrade_policy_mode" {
  description = "Specifies the mode of an upgrade to virtual machines in the scale set. Possible values are 'Manual', 'Rolling', or 'Automatic'."
  type        = string
  default     = "Manual"

  validation {
    condition     = contains(["Manual", "Rolling", "Automatic"], var.upgrade_policy_mode)
    error_message = "upgrade_policy_mode must be one of 'Manual', 'Rolling', or 'Automatic'."
  }
}

variable "automatic_os_upgrade" {
  description = "Whether automatic OS patches should be applied by Azure to your scale set. Defaults to false."
  type        = bool
  default     = false
}

variable "health_probe_id" {
  description = "Specifies the identifier for the load balancer health probe. Required when upgrade_policy_mode is set to 'Rolling'."
  type        = string
  default     = null
}

variable "rolling_upgrade_policy" {
  description = "Rolling upgrade policy configuration when upgrade_policy_mode is set to 'Rolling'."
  type = object({
    max_batch_instance_percent              = optional(number, 20)
    max_unhealthy_instance_percent          = optional(number, 20)
    max_unhealthy_upgraded_instance_percent = optional(number, 20)
    pause_time_between_batches              = optional(string, "PT0S")
  })
  default = null
}

variable "overprovision" {
  description = "Specifies whether the virtual machine scale set should be overprovisioned. Defaults to true."
  type        = bool
  default     = true
}

variable "single_placement_group" {
  description = "Specifies whether the scale set is limited to a single placement group with a maximum size of 100 virtual machines. Defaults to true."
  type        = bool
  default     = true
}

variable "priority" {
  description = "Specifies the priority for the Virtual Machines in the Scale Set. Possible values are 'Regular' and 'Low'. Changing this forces a new resource to be created."
  type        = string
  default     = "Regular"

  validation {
    condition     = contains(["Regular", "Low"], var.priority)
    error_message = "priority must be either 'Regular' or 'Low'."
  }
}

variable "eviction_policy" {
  description = "Specifies the eviction policy for Virtual Machines in this Scale Set when priority is 'Low'. Possible values are 'Deallocate' and 'Delete'."
  type        = string
  default     = null

  validation {
    condition     = var.eviction_policy == null || contains(["Deallocate", "Delete"], coalesce(var.eviction_policy, "Deallocate"))
    error_message = "eviction_policy must be either 'Deallocate' or 'Delete'."
  }
}

variable "zones" {
  description = "A collection of availability zones to spread the Virtual Machines over. Changing this forces a new resource to be created."
  type        = list(string)
  default     = null
}

variable "proximity_placement_group_id" {
  description = "The ID of the Proximity Placement Group to which this Virtual Machine Scale Set should be assigned."
  type        = string
  default     = null
}

variable "license_type" {
  description = "Specifies the Windows OS license type for Windows machines. Allowed values are 'Windows_Client' and 'Windows_Server'."
  type        = string
  default     = null
}

variable "storage_profile_os_disk" {
  description = "Storage profile OS disk configuration for the Virtual Machine Scale Set."
  type = object({
    name              = optional(string, null)
    caching           = optional(string, "ReadWrite")
    create_option     = optional(string, "FromImage")
    managed_disk_type = optional(string, "Standard_LRS")
    os_type           = optional(string, null)
    image             = optional(string, null)
    vhd_containers    = optional(list(string), null)
  })
  default = {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

variable "storage_profile_image_reference" {
  description = "Specifies the platform image or custom image reference for the Virtual Machine Scale Set."
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

variable "storage_profile_data_disks" {
  description = "List of storage profile data disks attached to each instance in the scale set."
  type = list(object({
    lun               = number
    caching           = optional(string, "ReadWrite")
    create_option     = optional(string, "Empty")
    disk_size_gb      = optional(number, 30)
    managed_disk_type = optional(string, "Standard_LRS")
  }))
  default = []
}

variable "os_profile" {
  description = "Operating system profile settings including computer name prefix and administrator credentials."
  type = object({
    computer_name_prefix = optional(string, "vmss")
    admin_username       = optional(string, "azureuser")
    admin_password       = optional(string, null)
    custom_data          = optional(string, null)
  })
  default = {
    computer_name_prefix = "vmss"
    admin_username       = "azureuser"
  }
}

variable "os_profile_linux_config" {
  description = "Linux operating system configuration including password authentication and SSH public keys."
  type = object({
    disable_password_authentication = optional(bool, false)
    ssh_keys = optional(list(object({
      path     = string
      key_data = optional(string, null)
    })), [])
  })
  default = null
}

variable "os_profile_windows_config" {
  description = "Windows operating system configuration including VM agent provisioning and automatic updates."
  type = object({
    provision_vm_agent        = optional(bool, true)
    enable_automatic_upgrades = optional(bool, false)
  })
  default = null
}

variable "network_profiles" {
  description = "List of network profile configurations for instances in the Virtual Machine Scale Set."
  type = list(object({
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
}

variable "identity" {
  description = "Managed Service Identity block for the Virtual Machine Scale Set."
  type = object({
    type         = optional(string, "SystemAssigned")
    identity_ids = optional(list(string), [])
  })
  default = null
}

variable "boot_diagnostics" {
  description = "Boot diagnostics configuration to capture serial output and screenshots of virtual machines."
  type = object({
    enabled     = optional(bool, true)
    storage_uri = string
  })
  default = null
}

variable "extensions" {
  description = "List of virtual machine scale set extension profiles."
  type = list(object({
    name                       = string
    publisher                  = string
    type                       = string
    type_handler_version       = string
    auto_upgrade_minor_version = optional(bool, true)
    provision_after_extensions = optional(list(string), [])
    settings                   = optional(string, null)
    protected_settings         = optional(string, null)
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Virtual Machine Scale Set."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Custom timeout durations for resource operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}
