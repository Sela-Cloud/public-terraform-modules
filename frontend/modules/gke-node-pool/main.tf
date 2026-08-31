module "gke_standard_node_pool" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/gke-standard-node-pool?ref=v0.6.13"
  for_each = var.gke_node_pool

  project_id         = var.project_id
  name               = each.value.name
  location           = each.value.location
  cluster_name       = each.value.cluster_name
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
  enable_workload_identity    = each.value.enable_workload_identity
  max_pods_per_node           = each.value.max_pods_per_node
  enable_image_streaming      = each.value.enable_image_streaming
}
