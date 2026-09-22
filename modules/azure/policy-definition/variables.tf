variable "name" {
  description = "(Required) The name of the Policy Definition. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{1,128}$", var.name))
    error_message = "The policy definition name must be between 1 and 128 characters and can only contain letters, numbers, underscores, hyphens, and periods."
  }
}

variable "display_name" {
  description = "(Required) The display name of the Policy Definition."
  type        = string
}

variable "policy_type" {
  description = "(Optional) The policy type. Possible values are BuiltIn, Custom, NotSpecified and Static. Defaults to Custom. Changing this forces a new resource to be created."
  type        = string
  default     = "Custom"

  validation {
    condition     = contains(["BuiltIn", "Custom", "NotSpecified", "Static"], var.policy_type)
    error_message = "The policy_type must be one of: BuiltIn, Custom, NotSpecified, Static."
  }
}

variable "mode" {
  description = "(Optional) The policy resource manager mode that determines which resource types will be evaluated. Possible values are All, Indexed, NotSpecified, Microsoft.CustomerLockbox.Data, Microsoft.DataCatalog.Data, Microsoft.KeyVault.Data, Microsoft.Kubernetes.Data, Microsoft.MachineLearningServices.Data, Microsoft.Network.Data, Microsoft.Synapse.Data. Defaults to All."
  type        = string
  default     = "All"

  validation {
    condition = contains([
      "All",
      "Indexed",
      "NotSpecified",
      "Microsoft.CustomerLockbox.Data",
      "Microsoft.DataCatalog.Data",
      "Microsoft.KeyVault.Data",
      "Microsoft.Kubernetes.Data",
      "Microsoft.MachineLearningServices.Data",
      "Microsoft.Network.Data",
      "Microsoft.Synapse.Data"
    ], var.mode)
    error_message = "The mode must be a valid Azure Policy mode (e.g. All, Indexed, NotSpecified, or supported Microsoft.*.Data plane mode)."
  }
}

variable "description" {
  description = "(Optional) The description of the Policy Definition. Defaults to null."
  type        = string
  default     = null
}

variable "management_group_id" {
  description = "(Optional) The ID of the Management Group where this policy definition should be defined. If not specified, the policy will be created at the subscription level. Changing this forces a new resource to be created. Defaults to null."
  type        = string
  default     = null
}

variable "policy_rule" {
  description = "(Optional) The policy rule for the policy definition in JSON format. Defaults to null."
  type        = string
  default     = null
}

variable "metadata" {
  description = "(Optional) The metadata for the policy definition in JSON format. Defaults to null."
  type        = string
  default     = null
}

variable "parameters" {
  description = "(Optional) Parameters for the policy definition in JSON format. Defaults to null."
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
