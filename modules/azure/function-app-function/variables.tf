variable "name" {
  description = "(Required) The name of the function. Changing this forces a new resource to be created."
  type        = string
}

variable "function_app_id" {
  description = "(Required) The ID of the Function App in which this function should reside. Changing this forces a new resource to be created."
  type        = string
}

variable "config_json" {
  description = "(Required) The config for this Function in JSON format (bindings, triggers, and returns)."
  type        = string
}

variable "enabled" {
  description = "(Optional) Should this function be enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "language" {
  description = "(Optional) The language the Function is written in. Possible values include CSharp, Custom, Java, Javascript, Python, PowerShell, and TypeScript. Defaults to null."
  type        = string
  default     = null

  validation {
    condition     = var.language == null ? true : contains(["CSharp", "Custom", "Java", "Javascript", "Python", "PowerShell", "TypeScript"], var.language)
    error_message = "The language must be one of: CSharp, Custom, Java, Javascript, Python, PowerShell, or TypeScript."
  }
}

variable "files" {
  description = "(Optional) A list of file blocks representing source code files for the function. Defaults to []."
  type = list(object({
    name    = string
    content = string
  }))
  default = []
}

variable "test_data" {
  description = "(Optional) The test data for the function in JSON format. Defaults to null."
  type        = string
  default     = null
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
