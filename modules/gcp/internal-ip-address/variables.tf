variable "project_id" {
  description = "Project where the address is created."
  type        = string
}

variable "name" {
  description = "Name of the reserved address."
  type        = string
}

variable "region" {
  description = "Region to reserve the address in."
  type        = string
}

variable "network" {
  description = "Network for the address."
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork for the address."
  type        = string
}

variable "purpose" {
  description = "GCE_ENDPOINT (non-shared) or SHARED_LOADBALANCER_VIP."
  type        = string
  default     = "GCE_ENDPOINT"

  validation {
    condition     = contains(["GCE_ENDPOINT", "SHARED_LOADBALANCER_VIP"], var.purpose)
    error_message = "purpose must be 'GCE_ENDPOINT' or 'SHARED_LOADBALANCER_VIP'."
  }
}

variable "assign_automatically" {
  description = "If true, GCP assigns the address automatically. If false, address must be set to a specific IP to reserve."
  type        = bool
  default     = true
}

variable "address" {
  description = "A specific IP address to reserve. Only used when assign_automatically is false."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the address."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to the address."
  type        = map(string)
  default     = {}
}
