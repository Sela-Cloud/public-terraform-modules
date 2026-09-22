variable "name" {
  description = "(Required) Specifies the name of the Bastion Host. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The Bastion Host name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, underscores, hyphens, or periods."
  }
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Bastion Host. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the Bastion Host should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "ip_configuration" {
  description = "(Required) An ip_configuration block for the Bastion Host. Subnet must be named AzureBastionSubnet with prefix /26 or larger."
  type = object({
    name                 = optional(string, "configuration")
    subnet_id            = string
    public_ip_address_id = optional(string, null)
  })
}

variable "sku" {
  description = "(Optional) The SKU of the Bastion Host. Possible values are Developer, Basic, Standard, and Premium. Defaults to Standard."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Developer", "Basic", "Standard", "Premium"], var.sku)
    error_message = "The sku must be one of: Developer, Basic, Standard, Premium."
  }
}

variable "scale_units" {
  description = "(Optional) The number of scale units with which to provision the Bastion Host. Possible values are between 2 and 50. Defaults to 2."
  type        = number
  default     = 2

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "The scale_units must be between 2 and 50."
  }
}

variable "copy_paste_enabled" {
  description = "(Optional) Is Copy/Paste feature enabled for the Bastion Host. Defaults to true."
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "(Optional) Is File Copy feature enabled for the Bastion Host. Only supported on Standard and Premium SKUs. Defaults to false."
  type        = bool
  default     = false
}

variable "shareable_link_enabled" {
  description = "(Optional) Is Shareable Link feature enabled for the Bastion Host. Only supported on Standard and Premium SKUs. Defaults to false."
  type        = bool
  default     = false
}

variable "tunneling_enabled" {
  description = "(Optional) Is Native Client Tunneling feature enabled for the Bastion Host. Only supported on Standard and Premium SKUs. Defaults to false."
  type        = bool
  default     = false
}

variable "ip_connect_enabled" {
  description = "(Optional) Is IP Connect feature enabled for the Bastion Host. Only supported on Standard and Premium SKUs. Defaults to false."
  type        = bool
  default     = false
}

variable "session_recording_enabled" {
  description = "(Optional) Is Session Recording feature enabled for the Bastion Host. Only supported on Premium SKU. Defaults to false."
  type        = bool
  default     = false
}

variable "kerberos_enabled" {
  description = "(Optional) Is Kerberos authentication feature enabled for the Bastion Host. Only supported on Standard and Premium SKUs. Defaults to false."
  type        = bool
  default     = false
}

variable "zones" {
  description = "(Optional) Specifies a list of Availability Zones in which this Bastion Host should be located. Defaults to null."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the Bastion Host. Defaults to {}."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "(Optional) Custom timeout durations for resource operations."
  type = object({
    create = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}
