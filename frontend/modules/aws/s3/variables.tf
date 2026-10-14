variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "s3" {
  description = "Map of S3 bucket configurations to deploy, keyed by bucket name."
  type = map(object({
    bucket_name         = optional(string, null)
    object_key          = string
    object_content      = optional(string, "")
    object_content_type = optional(string, "text/plain")
    tags                = optional(map(string), {})
    object_tags         = optional(map(string), {})
    versioning_enabled  = optional(bool, true)
    force_destroy       = optional(bool, false)

    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)

    object_ownership = optional(string, "BucketOwnerEnforced")

    kms_master_key_id  = optional(string, null)
    bucket_key_enabled = optional(bool, true)

    logging_target_bucket = optional(string, null)
    logging_target_prefix = optional(string, "log/")

    acceleration_status = optional(string, null)

    object_lock_enabled = optional(bool, false)
    object_lock_mode    = optional(string, "GOVERNANCE")
    object_lock_days    = optional(number, null)
    object_lock_years   = optional(number, null)

    cors_rules = optional(list(object({
      id              = optional(string, null)
      allowed_headers = optional(list(string), ["*"])
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string), null)
      max_age_seconds = optional(number, null)
    })), [])

    acl = optional(string, null)
    grants = optional(list(object({
      grantee = object({
        id            = optional(string, null)
        type          = string
        uri           = optional(string, null)
        email_address = optional(string, null)
      })
      permission = string
    })), [])
    owner_id = optional(string, null)

    website_enabled        = optional(bool, false)
    website_index_document = optional(string, "index.html")
    website_error_document = optional(string, null)
    website_redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string, null)
    }), null)

    lifecycle_enabled                  = optional(bool, false)
    lifecycle_expiration_days          = optional(number, 365)
    noncurrent_version_expiration_days = optional(number, 30)

    bucket_policy = optional(string, null)
  }))
  default = {}
}
