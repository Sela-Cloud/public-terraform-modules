variable "app_service_certificate" {
  description = "Map of Azure App Service Certificate configurations to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    key_vault_secret_id = optional(string, null)
    key_vault_id        = optional(string, null)
    pfx_blob            = optional(string, null)
    password            = optional(string, null)
    app_service_plan_id = optional(string, null)
    tags                = optional(map(string), {})
  }))
  default = {}
}
