resource "azurerm_storage_mover" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = var.description
  tags                = var.tags
}

resource "azurerm_storage_mover_agent" "this" {
  for_each = var.agents

  name                     = coalesce(each.value.name, each.key)
  storage_mover_id         = azurerm_storage_mover.this.id
  arc_virtual_machine_id   = each.value.arc_virtual_machine_id
  arc_virtual_machine_uuid = each.value.arc_virtual_machine_uuid
  description              = each.value.description
}

resource "azurerm_storage_mover_project" "this" {
  for_each = var.projects

  name             = coalesce(each.value.name, each.key)
  storage_mover_id = azurerm_storage_mover.this.id
  description      = each.value.description
}

resource "azurerm_storage_mover_source_endpoint" "this" {
  for_each = var.source_endpoints

  name             = coalesce(each.value.name, each.key)
  storage_mover_id = azurerm_storage_mover.this.id
  host             = each.value.host
  export           = each.value.export
  nfs_version      = each.value.nfs_version
  description      = each.value.description
}

resource "azurerm_storage_mover_target_endpoint" "this" {
  for_each = var.target_endpoints

  name                   = coalesce(each.value.name, each.key)
  storage_mover_id       = azurerm_storage_mover.this.id
  storage_account_id     = each.value.storage_account_id
  storage_container_name = each.value.storage_container_name
  description            = each.value.description
}

resource "azurerm_storage_mover_job_definition" "this" {
  for_each = var.job_definitions

  name                     = coalesce(each.value.name, each.key)
  storage_mover_project_id = each.value.storage_mover_project_id != null ? each.value.storage_mover_project_id : azurerm_storage_mover_project.this[each.value.project_name].id
  source_name              = each.value.source_name
  target_name              = each.value.target_name
  copy_mode                = each.value.copy_mode
  agent_name               = each.value.agent_name
  source_sub_path          = each.value.source_sub_path
  target_sub_path          = each.value.target_sub_path
  description              = each.value.description
}
