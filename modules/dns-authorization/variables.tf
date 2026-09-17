variable "project_id" {
  description = "Project where the DNS authorization is created."
  type        = string
}

variable "name" {
  description = "Name of the DNS authorization resource."
  type        = string
}

variable "domain" {
  description = "The domain being authorized. Covers the domain and its wildcard, e.g. authorizing example.com also covers *.example.com."
  type        = string
}

variable "description" {
  description = "Description of the DNS authorization."
  type        = string
  default     = null
}

variable "type" {
  description = "FIXED_RECORD (default) uses one shared CNAME per domain. PER_PROJECT_RECORD uses a project-specific CNAME, so the same domain can be authorized independently in more than one project without the two colliding -- required if you need to provision certificates for the same domain in multiple projects. PER_PROJECT_RECORD only supports certificates issued by Google Trust Services."
  type        = string
  default     = "FIXED_RECORD"

  validation {
    condition     = contains(["FIXED_RECORD", "PER_PROJECT_RECORD"], var.type)
    error_message = "type must be 'FIXED_RECORD' or 'PER_PROJECT_RECORD'."
  }
}
