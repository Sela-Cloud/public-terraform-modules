variable "name" {
  description = "Name of the Cloud Map HTTP namespace. Services joining it reach each other by the client aliases they register here."
  type        = string
}

variable "description" {
  description = "Description of the namespace."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the namespace."
  type        = map(string)
  default     = {}
}
