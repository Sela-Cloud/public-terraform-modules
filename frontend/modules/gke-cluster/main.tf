locals {
  standard_node_pools = merge([
    for cluster_key, cluster in var.gke_cluster : cluster.mode == "standard" ? {
      for node_pool in cluster.node_pools : "${cluster_key}-${node_pool.name}" => merge(node_pool, {
        cluster_key = cluster_key
        project_id  = cluster.project_id
        location    = cluster.location_type == "zonal" ? cluster.zone : cluster.region
      })
    } : {}
  ]...)
}

module "gke_autopilot" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/gke-autopilot?ref=v0.4.7"

  for_each = {
    for key, cluster in var.gke_cluster : key => cluster
    if cluster.mode == "autopilot"
  }

  project_id                          = each.value.project_id
  name                                = each.value.name
  location                            = each.value.region
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
  enable_network_policy               = each.value.enable_network_policy
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
}

module "gke_standard_cluster" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/gke-standard-cluster?ref=v0.4.7"

  for_each = {
    for key, cluster in var.gke_cluster : key => cluster
    if cluster.mode == "standard"
  }

  project_id                          = each.value.project_id
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

module "gke_standard_node_pool" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/gke-standard-node-pool?ref=v0.4.7"
  for_each = local.standard_node_pools

  project_id         = each.value.project_id
  name               = each.value.name
  location           = each.value.location
  cluster_name       = module.gke_standard_cluster[each.value.cluster_key].name
  node_locations     = each.value.node_locations
  initial_node_count = each.value.initial_node_count
  autoscaling = {
    enabled        = each.value.autoscaling_enabled
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }
  auto_repair                 = each.value.auto_repair
  auto_upgrade                = each.value.auto_upgrade
  max_surge                   = each.value.max_surge
  max_unavailable             = each.value.max_unavailable
  machine_type                = each.value.machine_type
  disk_size_gb                = each.value.disk_size_gb
  disk_type                   = each.value.disk_type
  image_type                  = each.value.image_type
  spot                        = each.value.spot
  service_account             = try(trimspace(each.value.service_account), "") != "" ? each.value.service_account : null
  oauth_scopes                = each.value.oauth_scopes
  labels                      = each.value.labels
  tags                        = each.value.tags
  metadata                    = each.value.metadata
  taints                      = each.value.taints
  enable_secure_boot          = each.value.enable_secure_boot
  enable_integrity_monitoring = each.value.enable_integrity_monitoring
  enable_workload_identity    = var.gke_cluster[each.value.cluster_key].enable_workload_identity
  max_pods_per_node           = each.value.max_pods_per_node
  enable_image_streaming      = each.value.enable_image_streaming
}
