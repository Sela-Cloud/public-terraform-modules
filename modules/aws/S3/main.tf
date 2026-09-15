resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
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

# S3 has no physical folders. A slash in an object key creates the familiar
# folder-like hierarchy in the AWS console, for example: uploads/hello.txt.
resource "aws_s3_object" "this" {
  bucket       = aws_s3_bucket.this.id
  key          = var.object_key
  content      = var.object_content
  content_type = var.object_content_type
  tags         = var.object_tags

  server_side_encryption = "AES256"
}