variable "project_id" {
  description = "Project where the service connection policy is created."
  type        = string
}

variable "name" {
  description = "Name of the service connection policy."
  type        = string
}

variable "location" {
  description = "Region the policy applies to."
  type        = string
}

variable "network" {
  description = "The consumer VPC network this policy authorizes PSC connections into."
  type        = string
}

variable "description" {
  description = "Free-text description of the policy."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to the policy."
  type        = map(string)
  default     = {}
}

variable "service_class" {
  description = "Producer service class this policy authorizes (e.g. 'gcp-memorystore-redis' for Memorystore for Redis Cluster/Valkey)."
  type        = string
  default     = "gcp-memorystore-redis"
}

variable "subnetworks" {
  description = "Subnetworks authorized for PSC connections under this policy."
  type        = list(string)

  validation {
    condition     = length(var.subnetworks) > 0
    error_message = "At least one subnetwork is required."
  }
}

variable "psc_connection_limit" {
  description = "Maximum number of PSC connections allowed under this policy."
  type        = number
  default     = null
}
