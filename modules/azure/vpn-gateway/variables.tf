variable "name" {
  description = "(Required) The name which should be used for this VPN Gateway. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The VPN Gateway name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, underscores, hyphens, or periods."
  }
}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group in which this VPN Gateway should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure location where this VPN Gateway should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "virtual_hub_id" {
  description = "(Required) The ID of the Virtual Hub in which the VPN Gateway should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "scale_unit" {
  description = "(Optional) The Scale Unit for this VPN Gateway. Defaults to 1."
  type        = number
  default     = 1

  validation {
    condition     = var.scale_unit >= 1 && var.scale_unit <= 100
    error_message = "The scale_unit must be between 1 and 100."
  }
}

variable "bgp_settings" {
  description = "(Optional) A bgp_settings block for configuring Border Gateway Protocol on the VPN Gateway. Defaults to null."
  type = object({
    asn                    = optional(number, 65515)
    peer_weight            = optional(number, 0)
    instance_0_custom_ips  = optional(list(string), [])
    instance_1_custom_ips  = optional(list(string), [])
  })
  default = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the VPN Gateway. Defaults to {}."
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
