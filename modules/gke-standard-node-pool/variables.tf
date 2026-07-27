variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "node_locations" {
  type    = list(string)
  default = []
}

variable "initial_node_count" {
  type    = number
  default = 1
}

variable "autoscaling" {
  type = object({
    enabled        = bool
    min_node_count = optional(number)
    max_node_count = optional(number)
  })
  default = {
    enabled        = true
    min_node_count = 1
    max_node_count = 3
  }
}

variable "auto_repair" {
  type    = bool
  default = true
}

variable "auto_upgrade" {
  type    = bool
  default = true
}

variable "max_surge" {
  type    = number
  default = 1
}

variable "max_unavailable" {
  type    = number
  default = 0
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "disk_size_gb" {
  type    = number
  default = 100
}

variable "disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "image_type" {
  type    = string
  default = "COS_CONTAINERD"
}

variable "spot" {
  type    = bool
  default = false
}

variable "service_account" {
  type    = string
  default = null
}

variable "oauth_scopes" {
  type    = list(string)
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "metadata" {
  type = map(string)
  default = {
    disable-legacy-endpoints = "true"
  }
}

variable "taints" {
  type = map(object({
    key    = string
    value  = optional(string)
    effect = string
  }))
  default = {}
}

variable "enable_secure_boot" {
  type    = bool
  default = true
}

variable "enable_integrity_monitoring" {
  type    = bool
  default = true
}

variable "enable_workload_identity" {
  type    = bool
  default = true
}

variable "max_pods_per_node" {
  type    = number
  default = null
}
