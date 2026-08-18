variable "project_id" {
  description = "GCP Project ID that owns the parent GKE Standard cluster."
  type        = string
}

variable "gke_node_pool" {
  description = "GKE Standard node pools configured through the Sela Deployer catalog. One map entry is exactly one node pool on an existing Standard cluster, so a node pool can be removed without touching its cluster or its sibling pools."
  type = map(object({
    node_pool_key            = string
    cluster_name             = string
    location                 = string
    name                     = string
    enable_workload_identity = optional(bool, true)
    node_locations           = optional(list(string), [])
    initial_node_count       = optional(number, 1)
    autoscaling_enabled      = optional(bool, true)
    min_node_count           = optional(number, 1)
    max_node_count           = optional(number, 3)
    auto_repair              = optional(bool, true)
    auto_upgrade             = optional(bool, true)
    max_surge                = optional(number, 1)
    max_unavailable          = optional(number, 0)
    machine_type             = optional(string, "e2-medium")
    disk_size_gb             = optional(number, 100)
    disk_type                = optional(string, "pd-balanced")
    image_type               = optional(string, "COS_CONTAINERD")
    spot                     = optional(bool, false)
    service_account          = optional(string)
    oauth_scopes             = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
    labels                   = optional(map(string), {})
    tags                     = optional(list(string), [])
    metadata                 = optional(map(string), { disable-legacy-endpoints = "true" })
    taints = optional(map(object({
      key    = string
      value  = optional(string)
      effect = string
    })), {})
    enable_secure_boot          = optional(bool, true)
    enable_integrity_monitoring = optional(bool, true)
    max_pods_per_node           = optional(number)
    enable_image_streaming      = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for node_pool in values(var.gke_node_pool) :
      trimspace(node_pool.cluster_name) != "" && trimspace(node_pool.location) != ""
    ])
    error_message = "Every node pool must name the GKE Standard cluster that hosts it and that cluster's location."
  }

  validation {
    condition = alltrue([
      for node_pool in values(var.gke_node_pool) :
      !node_pool.autoscaling_enabled || node_pool.max_node_count >= node_pool.min_node_count
    ])
    error_message = "Node-pool maximum node count must be greater than or equal to the minimum node count."
  }
}
