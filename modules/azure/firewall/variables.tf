variable "name" {
  description = "(Required) Specifies the name of the Azure Firewall. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "Firewall name must be 1-80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group in which the Azure Firewall should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "sku_name" {
  description = "(Required) SKU name of the Firewall. Possible values are AZFW_VNet and AZFW_Hub. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.sku_name)
    error_message = "sku_name must be either 'AZFW_VNet' or 'AZFW_Hub'."
  }
}

variable "sku_tier" {
  description = "(Required) SKU tier of the Firewall. Possible values are Basic, Standard, and Premium. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be one of: 'Basic', 'Standard', or 'Premium'."
  }
}

variable "ip_configuration" {
  description = "(Optional) A list of ip_configuration blocks. Used when sku_name is AZFW_VNet. The first configuration must include subnet_id (AzureFirewallSubnet)."
  type = list(object({
    name                 = string
    subnet_id            = optional(string, null)
    public_ip_address_id = optional(string, null)
  }))
  default = []
}

variable "management_ip_configuration" {
  description = "(Optional) A management_ip_configuration block. Required when sku_tier is Basic or when forced tunneling is enabled. Subnet must be AzureFirewallManagementSubnet."
  type = object({
    name                 = string
    subnet_id            = string
    public_ip_address_id = string
  })
  default = null
}

variable "virtual_hub" {
  description = "(Optional) A virtual_hub block. Used when sku_name is AZFW_Hub to deploy inside an Azure Virtual WAN Hub."
  type = object({
    virtual_hub_id  = string
    public_ip_count = optional(number, 1)
  })
  default = null
}

variable "firewall_policy_id" {
  description = "(Optional) The ID of the Firewall Policy associated with this Firewall."
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "(Optional) A list of DNS server IP addresses used by the Azure Firewall for name resolution."
  type        = list(string)
  default     = []
}

variable "dns_proxy_enabled" {
  description = "(Optional) Whether DNS proxy is enabled on the Azure Firewall. Defaults to false."
  type        = bool
  default     = false
}

variable "threat_intel_mode" {
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are Off, Alert, and Deny. Defaults to Alert."
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "threat_intel_mode must be one of: 'Off', 'Alert', or 'Deny'."
  }
}

variable "zones" {
  description = "(Optional) A list of Availability Zones in which this Azure Firewall should be deployed."
  type        = list(string)
  default     = []
}

variable "private_ip_ranges" {
  description = "(Optional) A list of SNAT private CIDR IP ranges or ['IANAPrivateRanges']. Defaults to null."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the Azure Firewall. Defaults to {}."
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
