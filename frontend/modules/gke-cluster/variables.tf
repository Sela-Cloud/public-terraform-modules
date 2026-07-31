variable "gke_cluster" {
  description = "GKE clusters configured through the Sela Deployer catalog."

  type = map(object({
    name                          = string
    project_id                    = string
    mode                          = string
    region                        = string
    location_type                 = optional(string, "regional")
    zone                          = optional(string)
    description                   = optional(string)
    node_locations                = optional(list(string), [])
    network                       = string
    subnetwork                    = string
    cluster_secondary_range_name  = optional(string)
    services_secondary_range_name = optional(string)
    labels                        = optional(map(string), {})
    deletion_protection           = optional(bool, true)
    release_channel               = optional(string, "REGULAR")
    min_master_version            = optional(string)
    private_nodes                 = optional(bool, true)
    enable_private_endpoint       = optional(bool, false)
    master_ipv4_cidr_block        = optional(string)
    master_global_access          = optional(bool, false)
    master_authorized_networks    = optional(map(string), {})
    enable_dataplane_v2           = optional(bool, true)
    enable_network_policy         = optional(bool, true)
    enable_binary_authorization   = optional(bool, false)
    enable_workload_identity      = optional(bool, true)
    groups_for_rbac               = optional(string)
    database_encryption_key_name  = optional(string)
    enable_http_load_balancing    = optional(bool, true)
    enable_managed_prometheus     = optional(bool, true)
    logging_components            = optional(set(string), ["SYSTEM_COMPONENTS", "WORKLOADS"])
    monitoring_components         = optional(set(string), ["SYSTEM_COMPONENTS"])
    fleet_project                 = optional(string)
    enable_backup_agent           = optional(bool, false)
    enable_filestore_csi_driver   = optional(bool, false)
    enable_secret_manager_addon   = optional(bool, false)
    dns_endpoint_config = optional(object({
      allow_external_traffic = optional(bool, false)
    }))
    enable_ip_access                    = optional(bool, true)
    gateway_api_channel                 = optional(string, "CHANNEL_DISABLED")
    maintenance_daily_window_start_time = optional(string)
    maintenance_exclusions = optional(list(object({
      name       = string
      start_time = string
      end_time   = string
      scope      = optional(string)
    })), [])
    enable_node_auto_provisioning = optional(bool, false)
    autoscaling_profile           = optional(string, "BALANCED")
    node_pools = optional(list(object({
      name                = string
      node_locations      = optional(list(string), [])
      initial_node_count  = optional(number, 1)
      autoscaling_enabled = optional(bool, true)
      min_node_count      = optional(number, 1)
      max_node_count      = optional(number, 3)
      auto_repair         = optional(bool, true)
      auto_upgrade        = optional(bool, true)
      max_surge           = optional(number, 1)
      max_unavailable     = optional(number, 0)
      machine_type        = optional(string, "e2-medium")
      disk_size_gb        = optional(number, 100)
      disk_type           = optional(string, "pd-balanced")
      image_type          = optional(string, "COS_CONTAINERD")
      spot                = optional(bool, false)
      service_account     = optional(string)
      oauth_scopes        = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
      labels              = optional(map(string), {})
      tags                = optional(list(string), [])
      metadata            = optional(map(string), { disable-legacy-endpoints = "true" })
      taints = optional(map(object({
        key    = string
        value  = optional(string)
        effect = string
      })), {})
      enable_secure_boot          = optional(bool, true)
      enable_integrity_monitoring = optional(bool, true)
      max_pods_per_node           = optional(number)
      enable_image_streaming      = optional(bool, false)
    })), [])
  }))

  default = {}

  validation {
    condition     = alltrue([for cluster in values(var.gke_cluster) : contains(["autopilot", "standard"], cluster.mode)])
    error_message = "GKE mode must be either autopilot or standard."
  }

  validation {
    condition     = alltrue([for cluster in values(var.gke_cluster) : cluster.mode != "autopilot" || cluster.location_type == "regional"])
    error_message = "Autopilot clusters must use a regional location."
  }

  validation {
    condition     = alltrue([for cluster in values(var.gke_cluster) : cluster.mode != "standard" || cluster.location_type != "zonal" || try(cluster.zone, null) != null])
    error_message = "A Standard zonal cluster requires a zone."
  }
}
