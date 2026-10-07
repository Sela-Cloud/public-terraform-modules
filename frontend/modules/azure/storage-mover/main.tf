module "storage_mover" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/storage-mover?ref=v0.8.14"
  for_each = var.storage_mover

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  description         = each.value.description
  tags                = each.value.tags
  agents              = each.value.agents
  projects            = each.value.projects
  source_endpoints    = each.value.source_endpoints
  target_endpoints    = each.value.target_endpoints
  job_definitions     = each.value.job_definitions
}
