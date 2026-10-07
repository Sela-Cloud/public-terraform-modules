variable "name" {
  description = "Domain name for the hosted zone, e.g. example.com."
  type        = string
}

variable "comment" {
  description = "Free-text description of the hosted zone."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether Terraform may delete all records in the zone when destroying it."
  type        = bool
  default     = false
}

variable "vpc_associations" {
  description = "VPCs to associate for a private hosted zone. Leave empty for a public zone."
  type = list(object({
    vpc_id     = string
    vpc_region = optional(string)
  }))
  default = []
}

variable "delegation_set_id" {
  description = "Reusable delegation set to assign fixed name servers from. Public zones only."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the hosted zone."
  type        = map(string)
  default     = {}
}
