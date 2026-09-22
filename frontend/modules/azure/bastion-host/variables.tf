variable "bastion_host" {
  description = "Map of Azure Bastion Host configurations."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    ip_configuration = object({
      name                 = optional(string, "configuration")
      subnet_id            = string
      public_ip_address_id = optional(string, null)
    })
    sku                       = optional(string, "Standard")
    scale_units               = optional(number, 2)
    copy_paste_enabled        = optional(bool, true)
    file_copy_enabled         = optional(bool, false)
    shareable_link_enabled    = optional(bool, false)
    tunneling_enabled         = optional(bool, false)
    ip_connect_enabled        = optional(bool, false)
    session_recording_enabled = optional(bool, false)
    kerberos_enabled          = optional(bool, false)
    zones                     = optional(list(string), null)
    tags                      = optional(map(string), {})
  }))
  default = {}
}
