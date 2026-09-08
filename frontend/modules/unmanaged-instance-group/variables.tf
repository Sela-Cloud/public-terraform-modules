variable "project_id" {
  description = "The GCP Project ID in which the instance groups are created."
  type        = string
}

variable "unmanaged_instance_group" {
  description = "The details of the Unmanaged Instance Groups to create, keyed by name."
  type = map(object({
    name        = string
    description = optional(string)
    zone        = string
    network     = optional(string)
    instances   = optional(list(string), [])
    named_ports = optional(list(object({
      name = string
      port = number
    })), [])
  }))
  default = {}
}
