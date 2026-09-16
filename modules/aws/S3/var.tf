variable "bucket_name" {
  description = "Globally unique name for the S3 bucket."
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "bucket_name must be between 3 and 63 characters long."
  }
}

variable "object_key" {
  description = "Object key to create. Include a prefix to place it in an S3 folder, for example uploads/hello.txt."
  type        = string

  validation {
    condition     = trimspace(var.object_key) != "" && !startswith(var.object_key, "/")
    error_message = "object_key must not be empty or start with a slash."
  }
}

variable "object_content" {
  description = "Text content written to the S3 object."
  type        = string
  default     = ""
}

variable "object_content_type" {
  description = "MIME type for the S3 object."
  type        = string
  default     = "text/plain"
}

variable "tags" {
  description = "Tags applied to the S3 bucket."
  type        = map(string)
  default     = {}
}

variable "object_tags" {
  description = "Tags applied to the S3 object."
  type        = map(string)
  default     = {}
}

variable "versioning_enabled" {
  description = "Whether to enable versioning for the S3 bucket."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Whether Terraform may delete all bucket objects when destroying the bucket."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Public Access Block
# ---------------------------------------------------------------------------

variable "block_public_acls" {
  description = "Whether to block public ACLs for the S3 bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether to block public bucket policies."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether to ignore public ACLs for the S3 bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether to restrict public bucket policies."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Ownership Controls
# ---------------------------------------------------------------------------

variable "object_ownership" {
  description = "Object ownership setting for the S3 bucket."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition = contains(
      [
        "BucketOwnerEnforced",
        "BucketOwnerPreferred",
        "ObjectWriter"
      ],
      var.object_ownership
    )

    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter."
  }
}

# ---------------------------------------------------------------------------
# KMS Encryption
# ---------------------------------------------------------------------------

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID or ARN used for server-side encryption. If null, AES256 is used."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether or not to use an S3 Bucket Key for SSE-KMS."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Access Logging
# ---------------------------------------------------------------------------

variable "logging_target_bucket" {
  description = "Target bucket for storing server access logs."
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for server access log objects."
  type        = string
  default     = "log/"
}

# ---------------------------------------------------------------------------
# Transfer Acceleration
# ---------------------------------------------------------------------------

variable "acceleration_status" {
  description = "Transfer Acceleration status (Enabled or Suspended)."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Object Lock
# ---------------------------------------------------------------------------

variable "object_lock_enabled" {
  description = "Whether to enable Object Lock configuration."
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "Default retention mode for Object Lock (GOVERNANCE or COMPLIANCE)."
  type        = string
  default     = "GOVERNANCE"
}

variable "object_lock_days" {
  description = "Number of days for default retention."
  type        = number
  default     = null
}

variable "object_lock_years" {
  description = "Number of years for default retention."
  type        = number
  default     = null
}

# ---------------------------------------------------------------------------
# CORS Configuration
# ---------------------------------------------------------------------------

variable "cors_rules" {
  description = "List of CORS rules to apply to the S3 bucket."
  type        = list(any)
  default     = []
}

# ---------------------------------------------------------------------------
# ACL & Grants
# ---------------------------------------------------------------------------

variable "acl" {
  description = "The canned ACL to apply to the bucket (e.g. private, public-read)."
  type        = string
  default     = null
}

variable "grants" {
  description = "List of ACL grant rules."
  type        = list(any)
  default     = []
}

variable "owner_id" {
  description = "The canonical user ID of the bucket owner (required when specifying grants)."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Website Configuration
# ---------------------------------------------------------------------------

variable "website_enabled" {
  description = "Whether to enable static website hosting."
  type        = bool
  default     = false
}

variable "website_index_document" {
  description = "The name of the index document for the website."
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "The name of the error document for the website."
  type        = string
  default     = null
}

variable "website_redirect_all_requests_to" {
  description = "Map containing redirect details for all website requests."
  type        = map(string)
  default     = null
}

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

variable "lifecycle_enabled" {
  description = "Whether to enable the default S3 lifecycle configuration."
  type        = bool
  default     = false
}

variable "lifecycle_expiration_days" {
  description = "Number of days after which current objects are deleted."
  type        = number
  default     = 365

  validation {
    condition     = var.lifecycle_expiration_days > 0
    error_message = "lifecycle_expiration_days must be greater than 0."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which noncurrent object versions are deleted."
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_expiration_days > 0
    error_message = "noncurrent_version_expiration_days must be greater than 0."
  }
}

# ---------------------------------------------------------------------------
# Bucket Policy
# ---------------------------------------------------------------------------

variable "bucket_policy" {
  description = "Optional JSON-formatted bucket policy."
  type        = string
  default     = null
}