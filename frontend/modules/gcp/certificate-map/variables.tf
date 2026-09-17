variable "project_id" {
  type = string
}

variable "certificate_map" {
  description = "Certificate Manager certificate maps configured through the Sela Deployer catalog."

  type = map(object({
    name        = string
    description = optional(string)
    entries = optional(list(object({
      entry_name   = string
      description  = optional(string)
      hostname     = optional(string)
      is_primary   = optional(bool, false)
      certificates = list(string)
      labels       = optional(map(string), {})
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for m in values(var.certificate_map) : alltrue([
        for e in m.entries : e.is_primary != (e.hostname != null && trimspace(e.hostname) != "")
      ])
    ])
    error_message = "Exactly one of hostname or is_primary must be set for each entry."
  }

  validation {
    condition = alltrue([
      for m in values(var.certificate_map) : alltrue([
        for e in m.entries : length(e.certificates) > 0
      ])
    ])
    error_message = "At least one certificate is required for each entry."
  }

  validation {
    condition = alltrue([
      for m in values(var.certificate_map) : length([for e in m.entries : e if e.is_primary]) <= 1
    ])
    error_message = "At most one entry per certificate map can be the primary entry."
  }
}
