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

variable "network_tier" {
  description = "Network service tier: PREMIUM or STANDARD."
  type        = string
  default     = "PREMIUM"

  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.network_tier)
    error_message = "network_tier must be 'PREMIUM' or 'STANDARD'."
  }
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
