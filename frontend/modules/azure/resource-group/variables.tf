variable "resource_group" {
  description = "Map of Azure Resource Group configurations to create."
  type = map(object({
    name       = string
    location   = string
    tags       = optional(map(string), {})
    managed_by = optional(string, null)
  }))
  default = {}
}
