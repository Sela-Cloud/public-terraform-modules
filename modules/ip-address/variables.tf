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
  description = "Network service tier: PREMIUM or STANDARD. Only applies to REGIONAL addresses -- google_compute_global_address has no network_tier."
  type        = string
  default     = "PREMIUM"

  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.network_tier)
    error_message = "network_tier must be 'PREMIUM' or 'STANDARD'."
  }
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
