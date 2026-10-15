resource "azurerm_container_app_environment" "environment" {
  name                                        = var.name
  resource_group_name                         = var.resource_group_name
  location                                    = var.location
  log_analytics_workspace_id                  = var.log_analytics_workspace_id
  logs_destination                            = var.logs_destination
  infrastructure_subnet_id                    = var.infrastructure_subnet_id
  infrastructure_resource_group_name          = var.infrastructure_resource_group_name
  internal_load_balancer_enabled              = var.internal_load_balancer_enabled == true ? true : null
  zone_redundancy_enabled                     = var.zone_redundancy_enabled == true ? true : null
  mutual_tls_enabled                          = var.mutual_tls_enabled
  public_network_access                       = var.public_network_access
  dapr_application_insights_connection_string = var.dapr_application_insights_connection_string
  tags                                        = var.tags

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "workload_profile" {
    for_each = var.workload_profiles
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }

  timeouts {
    create = "60m"
    update = "60m"
    read   = "5m"
    delete = "60m"
  }
}
