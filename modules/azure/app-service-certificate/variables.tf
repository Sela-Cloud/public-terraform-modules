variable "name" {
  description = "(Required) Specifies the name of the certificate. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the certificate. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "key_vault_secret_id" {
  description = "(Optional) The ID of the Key Vault Secret containing the certificate. Cannot be used when pfx_blob is specified."
  type        = string
  default     = null
  sensitive   = true
}

variable "key_vault_id" {
  description = "(Optional) The ID of the Key Vault to associate with the certificate."
  type        = string
  default     = null
}

variable "pfx_blob" {
  description = "(Optional) The base64-encoded contents of the PKCS#12 (.pfx) file. Cannot be used when key_vault_secret_id is specified."
  type        = string
  default     = null
  sensitive   = true
}

variable "password" {
  description = "(Optional) The password to access the certificate's private key in the PFX blob."
  type        = string
  default     = null
  sensitive   = true
}

variable "app_service_plan_id" {
  description = "(Optional) The ID of the App Service Plan assigned to the certificate. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
