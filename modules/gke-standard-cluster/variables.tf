variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "description" {
  type    = string
  default = null
}

variable "node_locations" {
  type    = list(string)
  default = []
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "cluster_secondary_range_name" {
  type    = string
  default = null
}

variable "services_secondary_range_name" {
  type    = string
  default = null
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}

variable "min_master_version" {
  type    = string
  default = null
}

variable "private_nodes" {
  type    = bool
  default = true
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = null
}

variable "master_global_access" {
  type    = bool
  default = false
}

variable "master_authorized_networks" {
  type    = map(string)
  default = {}
}

variable "enable_dataplane_v2" {
  type    = bool
  default = true
}

variable "enable_network_policy" {
  type    = bool
  default = true
}

variable "enable_binary_authorization" {
  type    = bool
  default = false
}

variable "enable_workload_identity" {
  type    = bool
  default = true
}

variable "groups_for_rbac" {
  type    = string
  default = null
}

variable "database_encryption_key_name" {
  type    = string
  default = null
}

variable "enable_http_load_balancing" {
  type    = bool
  default = true
}

variable "enable_managed_prometheus" {
  type    = bool
  default = true
}

variable "logging_components" {
  type    = set(string)
  default = ["SYSTEM_COMPONENTS", "WORKLOADS"]
}

variable "monitoring_components" {
  type    = set(string)
  default = ["SYSTEM_COMPONENTS"]
}

variable "fleet_project" {
  type    = string
  default = null
}

variable "enable_backup_agent" {
  type    = bool
  default = false
}

variable "maintenance_daily_window_start_time" {
  type    = string
  default = null
}

variable "maintenance_exclusions" {
  type = map(object({
    start_time = string
    end_time   = string
    scope      = optional(string)
  }))
  default = {}
}

variable "enable_node_auto_provisioning" {
  type    = bool
  default = false
}

variable "autoscaling_profile" {
  type    = string
  default = "BALANCED"
}
