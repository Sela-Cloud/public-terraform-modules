output "id" {
  description = "The ID of the Storage Mover."
  value       = azurerm_storage_mover.this.id
}

output "name" {
  description = "The name of the Storage Mover."
  value       = azurerm_storage_mover.this.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Storage Mover exists."
  value       = azurerm_storage_mover.this.resource_group_name
}

output "location" {
  description = "The Azure Region where the Storage Mover exists."
  value       = azurerm_storage_mover.this.location
}

output "projects" {
  description = "A map of all Storage Mover Projects created."
  value = {
    for k, v in azurerm_storage_mover_project.this : k => {
      id          = v.id
      name        = v.name
      description = v.description
    }
  }
}

output "agents" {
  description = "A map of all Storage Mover Agents created."
  value = {
    for k, v in azurerm_storage_mover_agent.this : k => {
      id                       = v.id
      name                     = v.name
      arc_virtual_machine_id   = v.arc_virtual_machine_id
      arc_virtual_machine_uuid = v.arc_virtual_machine_uuid
      description              = v.description
    }
  }
}

output "source_endpoints" {
  description = "A map of all Storage Mover Source Endpoints created."
  value = {
    for k, v in azurerm_storage_mover_source_endpoint.this : k => {
      id          = v.id
      name        = v.name
      host        = v.host
      export      = v.export
      nfs_version = v.nfs_version
      description = v.description
    }
  }
}

output "target_endpoints" {
  description = "A map of all Storage Mover Target Endpoints created."
  value = {
    for k, v in azurerm_storage_mover_target_endpoint.this : k => {
      id                     = v.id
      name                   = v.name
      storage_account_id     = v.storage_account_id
      storage_container_name = v.storage_container_name
      description            = v.description
    }
  }
}

output "job_definitions" {
  description = "A map of all Storage Mover Job Definitions created."
  value = {
    for k, v in azurerm_storage_mover_job_definition.this : k => {
      id                       = v.id
      name                     = v.name
      storage_mover_project_id = v.storage_mover_project_id
      source_name              = v.source_name
      target_name              = v.target_name
      copy_mode                = v.copy_mode
      agent_name               = v.agent_name
      source_sub_path          = v.source_sub_path
      target_sub_path          = v.target_sub_path
      description              = v.description
    }
  }
}
