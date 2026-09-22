variable "function_app_function" {
  description = "Map of Azure Function App Function configurations."
  type = map(object({
    name            = string
    function_app_id = string
    config_json     = string
    enabled         = optional(bool, true)
    language        = optional(string, null)
    files = optional(list(object({
      name    = string
      content = string
    })), [])
    test_data = optional(string, null)
  }))
  default = {}
}
