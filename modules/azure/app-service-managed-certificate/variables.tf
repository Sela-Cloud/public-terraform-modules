variable "custom_hostname_binding_id" {
  description = "(Required) The ID of the App Service Custom Hostname Binding for the Certificate. Changing this forces a new App Service Managed Certificate to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.custom_hostname_binding_id)) > 0
    error_message = "custom_hostname_binding_id must not be empty."
  }
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the App Service Managed Certificate."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "(Optional) An optional identifier or name for the managed certificate configuration."
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
