################################################################################
# AWS ECR Repository Variables
################################################################################

variable "name" {
  description = "Name of the repository."
  type        = string
  default     = "ecr-default"
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE."
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "The image_tag_mutability value must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "force_delete" {
  description = "If true, will delete the repository even if it contains images."
  type        = bool
  default     = false
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type to use for the repository. Valid values are 'AES256' or 'KMS'."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "The encryption_type value must be either 'AES256' or 'KMS'."
  }
}

variable "kms_key" {
  description = "The ARN of the KMS key to use when encryption_type is 'KMS'. If not specified when KMS is used, the default AWS managed key for ECR is used."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "lifecycle_policy" {
  description = "Raw JSON lifecycle policy document (image expiration/retention rules). Null to leave the repository without a lifecycle policy."
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "Raw JSON repository policy document (cross-account access/permissions). Null to leave the repository without a resource policy."
  type        = string
  default     = null
}
