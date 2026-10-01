variable "name" {
  description = "(Required) Specifies the name of the Storage Mover. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the Resource Group in which the Storage Mover should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the Azure Region where the Storage Mover should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "description" {
  description = "(Optional) A description for the Storage Mover."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Storage Mover."
  type        = map(string)
  default     = {}
}

variable "agents" {
  description = "(Optional) Map of Storage Mover Agents to register with the Storage Mover."
  type = map(object({
    name                     = optional(string, null)
    arc_virtual_machine_id   = string
    arc_virtual_machine_uuid = string
    description              = optional(string, null)
  }))
  default = {}
}

variable "projects" {
  description = "(Optional) Map of Storage Mover Projects to create within the Storage Mover."
  type = map(object({
    name        = optional(string, null)
    description = optional(string, null)
  }))
  default = {}
}

variable "source_endpoints" {
  description = "(Optional) Map of Storage Mover Source Endpoints (NFS) to create."
  type = map(object({
    name        = optional(string, null)
    host        = string
    export      = optional(string, null)
    nfs_version = optional(string, "NFSauto")
    description = optional(string, null)
  }))
  default = {}
}

variable "target_endpoints" {
  description = "(Optional) Map of Storage Mover Target Endpoints (Azure Storage Container) to create."
  type = map(object({
    name                   = optional(string, null)
    storage_account_id     = string
    storage_container_name = string
    description            = optional(string, null)
  }))
  default = {}
}

variable "job_definitions" {
  description = "(Optional) Map of Storage Mover Job Definitions to create within projects."
  type = map(object({
    name                     = optional(string, null)
    project_name             = optional(string, null)
    storage_mover_project_id = optional(string, null)
    source_name              = string
    target_name              = string
    copy_mode                = optional(string, "Additive")
    agent_name               = optional(string, null)
    source_sub_path          = optional(string, null)
    target_sub_path          = optional(string, null)
    description              = optional(string, null)
  }))
  default = {}
}
