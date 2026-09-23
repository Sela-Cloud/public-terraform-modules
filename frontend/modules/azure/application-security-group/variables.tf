variable "application_security_group" {
  description = "Map of Azure Application Security Group configurations to create."
  type = map(object({
    name                  = optional(string, "asg-default")
    resource_group_name   = optional(string, "rg-default")
    location              = optional(string, "eastus")
    tags                  = optional(map(string), {})
    network_interface_ids = optional(list(string), [])
    timeouts = optional(object({
      create = optional(string, null)
      read   = optional(string, null)
      update = optional(string, null)
      delete = optional(string, null)
    }), {})
  }))
  default = {}
}
