variable "name" {
  description = "The name of the Local Network Gateway. Changing this forces a new resource to be created."
  type        = string
  default     = "lng-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9_])?$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Local Network Gateway name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the Local Network Gateway. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "The Azure Region where the Local Network Gateway should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "gateway_address" {
  description = "The gateway IP address in IPv4 format to connect with. Specify either gateway_address or gateway_fqdn."
  type        = string
  default     = null
}

variable "gateway_fqdn" {
  description = "The gateway FQDN to connect with. Specify either gateway_address or gateway_fqdn."
  type        = string
  default     = null
}

variable "address_space" {
  description = "The list of string CIDRs representing the address spaces the gateway exposes."
  type        = list(string)
  default     = []
}

variable "bgp_settings" {
  description = "A bgp_settings block for configuring Border Gateway Protocol on the Local Network Gateway. Defaults to null."
  type = object({
    asn                 = optional(number, 65510)
    bgp_peering_address = optional(string, null)
    peer_weight         = optional(number, 0)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Local Network Gateway."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Custom timeout durations for resource operations."
  type = object({
    create = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}
