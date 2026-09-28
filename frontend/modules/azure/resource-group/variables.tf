variable "resource_group" {
  description = "Map of Azure Resource Group configurations to create."
  type = map(object({
    name       = optional(string, "rg-default")
    location   = optional(string, "eastus")
    tags       = optional(map(string), {})
    managed_by = optional(string, null)
  }))
  default = {}
}
