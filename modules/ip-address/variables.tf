variable "project_id" {
  description = "Project where the address is created."
  type        = string
}

variable "name" {
  description = "Name of the reserved address."
  type        = string
}

variable "type" {
  description = "REGIONAL (google_compute_address) or GLOBAL (google_compute_global_address). These are different GCP resource types."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.type)
    error_message = "type must be 'REGIONAL' or 'GLOBAL'."
  }
}

variable "region" {
  description = "Region to reserve the address in. Required when type is REGIONAL; ignored for GLOBAL."
  type        = string
  default     = null
}

variable "ip_version" {
  description = "IPV4 or IPV6."
  type        = string
  default     = "IPV4"

  validation {
    condition     = contains(["IPV4", "IPV6"], var.ip_version)
    error_message = "ip_version must be 'IPV4' or 'IPV6'."
  }
}

variable "network_tier" {
  description = "Network service tier: PREMIUM or STANDARD. Only applies to REGIONAL EXTERNAL addresses -- global addresses and internal addresses have no network_tier."
  type        = string
  default     = "PREMIUM"

  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.network_tier)
    error_message = "network_tier must be 'PREMIUM' or 'STANDARD'."
  }
}

variable "address_type" {
  description = "EXTERNAL or INTERNAL. Only applies to REGIONAL addresses -- GLOBAL addresses in this module are always external."
  type        = string
  default     = "EXTERNAL"

  validation {
    condition     = contains(["EXTERNAL", "INTERNAL"], var.address_type)
    error_message = "address_type must be 'EXTERNAL' or 'INTERNAL'."
  }
}

variable "network" {
  description = "Network for an INTERNAL address."
  type        = string
  default     = null
}

variable "subnetwork" {
  description = "Subnetwork for an INTERNAL address."
  type        = string
  default     = null
}

variable "purpose" {
  description = "Purpose of an INTERNAL address: GCE_ENDPOINT (non-shared) or SHARED_LOADBALANCER_VIP."
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
