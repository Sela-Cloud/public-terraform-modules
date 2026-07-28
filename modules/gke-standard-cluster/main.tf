resource "google_container_cluster" "this" {
  project                  = var.project_id
  name                     = var.name
  location                 = var.location
  description              = var.description
  network                  = var.network
  subnetwork               = var.subnetwork
  node_locations           = length(var.node_locations) > 0 ? var.node_locations : null
  min_master_version       = var.min_master_version
  resource_labels          = var.labels
  deletion_protection      = var.deletion_protection
  remove_default_node_pool = true
  initial_node_count       = 1
  datapath_provider        = var.enable_dataplane_v2 ? "ADVANCED_DATAPATH" : "LEGACY_DATAPATH"

  dynamic "ip_allocation_policy" {
    for_each = var.cluster_secondary_range_name != null && var.services_secondary_range_name != null ? [1] : []

    content {
      cluster_secondary_range_name  = var.cluster_secondary_range_name
      services_secondary_range_name = var.services_secondary_range_name
    }
  }

  addons_config {
    http_load_balancing {
      disabled = !var.enable_http_load_balancing
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gke_backup_agent_config {
      enabled = var.enable_backup_agent
    }
  }

  dynamic "network_policy" {
    for_each = var.enable_network_policy && !var.enable_dataplane_v2 ? [1] : []
    content {
      enabled  = true
      provider = "CALICO"
    }
  }

  dynamic "binary_authorization" {
    for_each = var.enable_binary_authorization ? [1] : []
    content { evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE" }
  }

  dynamic "workload_identity_config" {
    for_each = var.enable_workload_identity ? [1] : []
    content { workload_pool = "${var.project_id}.svc.id.goog" }
  }

  dynamic "authenticator_groups_config" {
    for_each = var.groups_for_rbac != null ? [1] : []
    content { security_group = var.groups_for_rbac }
  }

  dynamic "database_encryption" {
    for_each = var.database_encryption_key_name != null ? [1] : []
    content {
      state    = "ENCRYPTED"
      key_name = var.database_encryption_key_name
    }
  }

  dynamic "private_cluster_config" {
    for_each = var.private_nodes ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
      master_global_access_config { enabled = var.master_global_access }
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          display_name = cidr_blocks.key
          cidr_block   = cidr_blocks.value
        }
      }
    }
  }

  logging_config { enable_components = var.logging_components }
  monitoring_config {
    enable_components = var.monitoring_components
    managed_prometheus { enabled = var.enable_managed_prometheus }
  }
  release_channel { channel = var.release_channel }

  dynamic "fleet" {
    for_each = var.fleet_project != null ? [1] : []
    content { project = var.fleet_project }
  }

  dynamic "cluster_autoscaling" {
    for_each = var.enable_node_auto_provisioning ? [1] : []
    content { autoscaling_profile = var.autoscaling_profile }
  }

  dynamic "maintenance_policy" {
    for_each = var.maintenance_daily_window_start_time != null || length(var.maintenance_exclusions) > 0 ? [1] : []
    content {
      dynamic "daily_maintenance_window" {
        for_each = var.maintenance_daily_window_start_time != null ? [1] : []
        content { start_time = var.maintenance_daily_window_start_time }
      }
      dynamic "maintenance_exclusion" {
        for_each = var.maintenance_exclusions
        content {
          exclusion_name = maintenance_exclusion.key
          start_time     = maintenance_exclusion.value.start_time
          end_time       = maintenance_exclusion.value.end_time
          dynamic "exclusion_options" {
            for_each = try(maintenance_exclusion.value.scope, null) != null ? [1] : []
            content { scope = maintenance_exclusion.value.scope }
          }
        }
      }
    }
  }
}
