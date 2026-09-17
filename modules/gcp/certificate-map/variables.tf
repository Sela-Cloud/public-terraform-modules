variable "project_id" {
  description = "Project where the certificate map is created."
  type        = string
}

variable "name" {
  description = "Name of the certificate map."
  type        = string
}

variable "description" {
  description = "Description of the certificate map."
  type        = string
  default     = null
}

variable "entries" {
  description = "Certificate map entries, keyed by entry name."

  type = map(object({
    description  = optional(string)
    hostname     = optional(string)
    is_primary   = optional(bool, false)
    certificates = list(string)
    labels       = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for e in values(var.entries) : e.is_primary != (e.hostname != null && trimspace(e.hostname) != "")
    ])
    error_message = "Exactly one of hostname or is_primary must be set for each entry."
  }

  validation {
    condition = alltrue([
      for e in values(var.entries) : length(e.certificates) > 0
    ])
    error_message = "At least one certificate is required for each entry."
  }

  validation {
    condition     = length([for e in values(var.entries) : e if e.is_primary]) <= 1
    error_message = "At most one entry can be the primary entry."
  }
}
