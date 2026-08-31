module "gke_standard_cluster" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/gke-standard-cluster?ref=v0.6.5"
  for_each = var.gke_standard_cluster

  project_id                          = var.project_id
  name                                = each.value.name
  location                            = each.value.location_type == "zonal" ? each.value.zone : each.value.region
  description                         = each.value.description
  node_locations                      = each.value.node_locations
  network                             = each.value.network
  subnetwork                          = each.value.subnetwork
  cluster_secondary_range_name        = try(trimspace(each.value.cluster_secondary_range_name), "") != "" ? each.value.cluster_secondary_range_name : null
  services_secondary_range_name       = try(trimspace(each.value.services_secondary_range_name), "") != "" ? each.value.services_secondary_range_name : null
  labels                              = each.value.labels
  deletion_protection                 = each.value.deletion_protection
  release_channel                     = each.value.release_channel
  min_master_version                  = try(trimspace(each.value.min_master_version), "") != "" ? each.value.min_master_version : null
  private_nodes                       = each.value.private_nodes
  enable_private_endpoint             = each.value.enable_private_endpoint
  master_ipv4_cidr_block              = try(trimspace(each.value.master_ipv4_cidr_block), "") != "" ? each.value.master_ipv4_cidr_block : null
  master_global_access                = each.value.master_global_access
  master_authorized_networks          = each.value.master_authorized_networks
  enable_dataplane_v2                 = each.value.enable_dataplane_v2
  enable_network_policy               = each.value.enable_dataplane_v2 ? false : each.value.enable_network_policy
  enable_binary_authorization         = each.value.enable_binary_authorization
  enable_workload_identity            = each.value.enable_workload_identity
  groups_for_rbac                     = try(trimspace(each.value.groups_for_rbac), "") != "" ? each.value.groups_for_rbac : null
  database_encryption_key_name        = try(trimspace(each.value.database_encryption_key_name), "") != "" ? each.value.database_encryption_key_name : null
  enable_http_load_balancing          = each.value.enable_http_load_balancing
  enable_managed_prometheus           = each.value.enable_managed_prometheus
  logging_components                  = each.value.logging_components
  monitoring_components               = each.value.monitoring_components
  fleet_project                       = try(trimspace(each.value.fleet_project), "") != "" ? each.value.fleet_project : null
  enable_backup_agent                 = each.value.enable_backup_agent
  enable_filestore_csi_driver         = each.value.enable_filestore_csi_driver
  enable_secret_manager_addon         = each.value.enable_secret_manager_addon
  dns_endpoint_config                 = each.value.dns_endpoint_config
  enable_ip_access                    = each.value.enable_ip_access
  gateway_api_channel                 = each.value.gateway_api_channel
  maintenance_daily_window_start_time = try(trimspace(each.value.maintenance_daily_window_start_time), "") != "" ? each.value.maintenance_daily_window_start_time : null
  maintenance_exclusions = {
    for exclusion in each.value.maintenance_exclusions : exclusion.name => {
      start_time = exclusion.start_time
      end_time   = exclusion.end_time
      scope      = try(trimspace(exclusion.scope), "") != "" ? exclusion.scope : null
    }
  }
  enable_node_auto_provisioning = each.value.enable_node_auto_provisioning
  autoscaling_profile           = each.value.autoscaling_profile
}
