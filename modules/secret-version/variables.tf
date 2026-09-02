variable "project_id" {
  description = "Project the secret belongs to."
  type        = string
}

variable "secret_name" {
  description = "Name of the secret this version belongs to."
  type        = string
}

variable "secret_data" {
  description = "The secret payload. Must be no larger than 64KiB."
  type        = string
}

variable "enabled" {
  description = "If false, the version is disabled rather than destroyed."
  type        = bool
  default     = true
}
