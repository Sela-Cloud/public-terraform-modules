resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

# Server-side encryption with KMS support
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_master_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_master_key_id
    }
    bucket_key_enabled = var.kms_master_key_id != null ? var.bucket_key_enabled : null
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Bucket ownership
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

# Access Logging Configuration
resource "aws_s3_bucket_logging" "this" {
  count  = var.logging_target_bucket != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

# Transfer Acceleration Configuration
resource "aws_s3_bucket_accelerate_configuration" "this" {
  count  = var.acceleration_status != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  status = var.acceleration_status
}

# Object Lock Configuration (WORM Compliance)
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.object_lock_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode  = var.object_lock_mode
      days  = var.object_lock_days
      years = var.object_lock_years
    }
  }
}

# CORS Configuration
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      id              = try(cors_rule.value.id, null)
      allowed_headers = try(cors_rule.value.allowed_headers, ["*"])
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
}

# ACL / Grant Configuration
resource "aws_s3_bucket_acl" "this" {
  count  = var.acl != null || length(var.grants) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id
  acl    = var.acl

  dynamic "access_control_policy" {
    for_each = length(var.grants) > 0 ? [1] : []
    content {
      dynamic "grant" {
        for_each = var.grants
        content {
          grantee {
            id            = try(grant.value.grantee.id, null)
            type          = grant.value.grantee.type
            uri           = try(grant.value.grantee.uri, null)
            email_address = try(grant.value.grantee.email_address, null)
          }
          permission = grant.value.permission
        }
      }
      owner {
        id = var.owner_id
      }
    }
  }

  depends_on = [aws_s3_bucket_ownership_controls.this]
}

# Static Website Hosting Configuration
resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.website_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.website_index_document
  }

  dynamic "error_document" {
    for_each = var.website_error_document != null ? [var.website_error_document] : []
    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website_redirect_all_requests_to != null ? [var.website_redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = try(redirect_all_requests_to.value.protocol, null)
    }
  }
}

# Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.lifecycle_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    id     = "default-lifecycle"
    status = "Enabled"

    filter {}

    expiration {
      days = var.lifecycle_expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }
}

# Optional bucket policy
resource "aws_s3_bucket_policy" "this" {
  count = var.bucket_policy != null ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}

# S3 Object
resource "aws_s3_object" "this" {
  bucket       = aws_s3_bucket.this.id
  key          = var.object_key
  content      = var.object_content
  content_type = var.object_content_type
  tags         = var.object_tags

  server_side_encryption = var.kms_master_key_id != null ? "aws:kms" : "AES256"
  kms_key_id             = var.kms_master_key_id
}