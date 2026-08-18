variable "project_id" {
  description = "GCP Project ID in which the Standard cluster will be provisioned."
  type        = string
}

variable "gke_standard_cluster" {
  description = "GKE Standard clusters configured through the Sela Deployer catalog. Node pools have their own lifecycle and are managed by the gke-node-pool module."
  type = map(object({
    name                          = string
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
  }))
  default = {}

  validation {
    condition = alltrue([
      for cluster in values(var.gke_standard_cluster) :
      contains(["regional", "zonal"], cluster.location_type)
    ])
    error_message = "Standard cluster location must be regional or zonal."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.gke_standard_cluster) :
      cluster.location_type != "zonal" || try(trimspace(cluster.zone), "") != ""
    ])
    error_message = "A Standard zonal cluster requires a zone."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.gke_standard_cluster) :
      contains(["RAPID", "REGULAR", "STABLE"], cluster.release_channel)
    ])
    error_message = "GKE release channel must be RAPID, REGULAR or STABLE."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.gke_standard_cluster) :
      cluster.private_nodes || !cluster.enable_private_endpoint
    ])
    error_message = "A private control-plane endpoint requires private nodes."
  }
}
