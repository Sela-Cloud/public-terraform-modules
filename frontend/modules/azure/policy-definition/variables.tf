variable "policy_definition" {
  description = "Map of Azure Policy Definition configurations."
  type = map(object({
    name                = string
    display_name        = string
    policy_type         = optional(string, "Custom")
    mode                = optional(string, "All")
    description         = optional(string, null)
    management_group_id = optional(string, null)
    policy_rule         = optional(string, null)
    parameters          = optional(string, null)
    metadata            = optional(string, null)
  }))
  default = {}
}
