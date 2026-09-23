variable "app_service_managed_certificate" {
  description = "Map of Azure App Service Managed Certificate configurations to create."
  type = map(object({
    name                       = optional(string, "cert-default")
    custom_hostname_binding_id = string
    tags                       = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string, null)
      read   = optional(string, null)
      update = optional(string, null)
      delete = optional(string, null)
    }), {})
  }))
  default = {}
}
