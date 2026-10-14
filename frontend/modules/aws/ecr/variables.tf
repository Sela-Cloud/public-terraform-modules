variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "ecr" {
  description = "Map of AWS ECR repository configurations to deploy, keyed by repository name."
  type = map(object({
    name                 = string
    image_tag_mutability = optional(string, "MUTABLE")
    force_delete         = optional(bool, false)
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "AES256")
    kms_key              = optional(string, null)
    tags                 = optional(map(string), {})
    lifecycle_policy     = optional(string, null)
    repository_policy    = optional(string, null)
  }))
  default = {}
}
