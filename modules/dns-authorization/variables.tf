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
