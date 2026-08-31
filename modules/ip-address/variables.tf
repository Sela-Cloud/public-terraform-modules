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
