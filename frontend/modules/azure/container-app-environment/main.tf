module "container_app_environment" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/container-app-environment?ref=v0.9.12"
  for_each = var.container_app_environment

  name                                        = each.value.name
  resource_group_name                         = each.value.resource_group_name
  location                                    = each.value.location
  log_analytics_workspace_id                  = each.value.log_analytics_workspace_id
  logs_destination                            = each.value.logs_destination
  infrastructure_subnet_id                    = each.value.infrastructure_subnet_id
  infrastructure_resource_group_name          = each.value.infrastructure_resource_group_name
  internal_load_balancer_enabled              = each.value.internal_load_balancer_enabled
  zone_redundancy_enabled                     = each.value.zone_redundancy_enabled
  mutual_tls_enabled                          = each.value.mutual_tls_enabled
  public_network_access                       = each.value.public_network_access
  dapr_application_insights_connection_string = each.value.dapr_application_insights_connection_string
  workload_profiles                           = each.value.workload_profiles
  identity                                    = each.value.identity
  tags                                        = each.value.tags
}
