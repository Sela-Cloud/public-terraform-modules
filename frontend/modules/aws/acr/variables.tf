variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "acr" {
  description = "Map of AWS ECR/ACR repository configurations to deploy, keyed by repository name."
  type = map(object({
    name                 = optional(string, "acr-default")
    image_tag_mutability = optional(string, "MUTABLE")
    force_delete         = optional(bool, false)
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "AES256")
    kms_key              = optional(string, null)
    tags                 = optional(map(string), {})
  }))
  default = {
    "acr-default" = {
      name                 = "acr-default"
      image_tag_mutability = "MUTABLE"
      force_delete         = false
      scan_on_push         = true
      encryption_type      = "AES256"
      kms_key              = null
      tags                 = {}
    }
  }
}
