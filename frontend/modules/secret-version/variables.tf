variable "project_id" {
  type = string
}

variable "secret_version" {
  description = "Secret Manager secret versions configured through the Sela Deployer catalog. Each attaches to an existing secret by name."

  type = map(object({
    version_label = string
    secret_name   = string
    secret_data   = string
    enabled       = optional(bool, true)
  }))
  default = {}

  validation {
    condition = alltrue([
      for v in values(var.secret_version) : trimspace(v.secret_data) != ""
    ])
    error_message = "secret_data is required."
  }
}
