variable "project_id" {
  description = "GCP project ID in which the GKE cluster is created."
  type        = string
}

variable "name" {
  description = "Name of the GKE cluster."
  type        = string
}

variable "location" {
  description = "Regional location for the Autopilot cluster."
  type        = string
}

variable "description" {
  description = "Optional cluster description."
  type        = string
  default     = null
}

variable "node_locations" {
  description = "Optional zones in the cluster region for cluster workloads."
  type        = list(string)
  default     = []
}

variable "network" {
  description = "VPC network name or self link."
  type        = string
}

variable "subnetwork" {
  description = "VPC subnetwork name or self link."
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "Existing secondary range used for Pod IP addresses."
  type        = string
  default     = null
}

variable "services_secondary_range_name" {
  description = "Existing secondary range used for Service IP addresses."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels applied to the cluster."
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Prevent Terraform from deleting the cluster."
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}

variable "min_master_version" {
  description = "Optional minimum control-plane version."
  type        = string
  default     = null
}

variable "private_nodes" {
  description = "Create nodes without public IP addresses."
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Expose the control plane only through its private endpoint."
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "RFC1918 /28 range for the private control-plane endpoint."
  type        = string
  default     = null
}

variable "master_global_access" {
  description = "Allow private control-plane access from other regions in the VPC."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "Named CIDR ranges allowed to reach the control plane."
  type        = map(string)
  default     = {}
}

variable "enable_dataplane_v2" {
  description = "Use GKE Dataplane V2. It is enabled by default for Autopilot."
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable Kubernetes NetworkPolicy enforcement."
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enforce the project Binary Authorization policy."
  type        = bool
  default     = false
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for Kubernetes service accounts."
  type        = bool
  default     = true
}

variable "groups_for_rbac" {
  description = "Google Group used for GKE RBAC, such as gke-security-groups@example.com."
  type        = string
  default     = null
}

variable "database_encryption_key_name" {
  description = "Cloud KMS key for application-layer encryption of Kubernetes Secrets."
  type        = string
  default     = null
}

variable "enable_http_load_balancing" {
  description = "Enable the GKE HTTP(S) load-balancing add-on. Autopilot requires it."
  type        = bool
  default     = true
}

variable "enable_managed_prometheus" {
  description = "Enable Google Cloud Managed Service for Prometheus."
  type        = bool
  default     = true
}

variable "logging_components" {
  description = "GKE log components sent to Cloud Logging."
  type        = set(string)
  default     = ["SYSTEM_COMPONENTS", "WORKLOADS"]
}

variable "monitoring_components" {
  description = "GKE metrics components sent to Cloud Monitoring."
  type        = set(string)
  default     = ["SYSTEM_COMPONENTS"]
}

variable "fleet_project" {
  description = "Fleet host project ID. Set to register the cluster with a Fleet."
  type        = string
  default     = null
}

variable "enable_backup_agent" {
  description = "Enable the Backup for GKE agent add-on."
  type        = bool
  default     = false
}

variable "maintenance_daily_window_start_time" {
  description = "Daily maintenance start time in HH:MM UTC."
  type        = string
  default     = null
}

variable "maintenance_exclusions" {
  description = "Named GKE maintenance exclusions."
  type = map(object({
    start_time = string
    end_time   = string
    scope      = optional(string)
  }))
  default = {}
}
