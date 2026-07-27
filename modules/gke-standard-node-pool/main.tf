resource "google_container_node_pool" "this" {
  project            = var.project_id
  name               = var.name
  location           = var.location
  cluster            = var.cluster_name
  node_locations     = length(var.node_locations) > 0 ? var.node_locations : null
  initial_node_count = var.initial_node_count
  max_pods_per_node  = var.max_pods_per_node

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  dynamic "autoscaling" {
    for_each = var.autoscaling.enabled ? [1] : []
    content {
      min_node_count = var.autoscaling.min_node_count
      max_node_count = var.autoscaling.max_node_count
    }
  }

  upgrade_settings {
    max_surge       = var.max_surge
    max_unavailable = var.max_unavailable
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = var.disk_type
    image_type      = var.image_type
    spot            = var.spot
    service_account = var.service_account
    oauth_scopes    = var.oauth_scopes
    labels          = var.labels
    tags            = var.tags
    metadata        = var.metadata

    shielded_instance_config {
      enable_secure_boot          = var.enable_secure_boot
      enable_integrity_monitoring = var.enable_integrity_monitoring
    }

    workload_metadata_config {
      mode = var.enable_workload_identity ? "GKE_METADATA" : "GCE_METADATA"
    }

    dynamic "taint" {
      for_each = var.taints
      content {
        key    = taint.value.key
        value  = try(taint.value.value, null)
        effect = taint.value.effect
      }
    }
  }
}
