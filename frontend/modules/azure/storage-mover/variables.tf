variable "storage_mover" {
  description = "Map of Azure Storage Mover configurations."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    description         = optional(string, null)
    tags                = optional(map(string), {})

    agents = optional(map(object({
      name                     = optional(string, null)
      arc_virtual_machine_id   = string
      arc_virtual_machine_uuid = string
      description              = optional(string, null)
    })), {})

    projects = optional(map(object({
      name        = optional(string, null)
      description = optional(string, null)
    })), {})

    source_endpoints = optional(map(object({
      name        = optional(string, null)
      host        = string
      export      = optional(string, null)
      nfs_version = optional(string, "NFSauto")
      description = optional(string, null)
    })), {})

    target_endpoints = optional(map(object({
      name                   = optional(string, null)
      storage_account_id     = string
      storage_container_name = string
      description            = optional(string, null)
    })), {})

    job_definitions = optional(map(object({
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
    })), {})
  }))
  default = {}
}
