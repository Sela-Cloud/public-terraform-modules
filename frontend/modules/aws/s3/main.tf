/******************************************
  AWS S3 Root Module
 *****************************************/

module "s3" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/s3?ref=v0.9.12"
  for_each = var.s3

  bucket_name         = coalesce(each.value.bucket_name, each.key)
  object_key          = each.value.object_key
  object_content      = each.value.object_content
  object_content_type = each.value.object_content_type
  tags                = each.value.tags
  object_tags         = each.value.object_tags
  versioning_enabled  = each.value.versioning_enabled
  force_destroy       = each.value.force_destroy

  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets

  object_ownership = each.value.object_ownership

  kms_master_key_id  = each.value.kms_master_key_id
  bucket_key_enabled = each.value.bucket_key_enabled

  logging_target_bucket = each.value.logging_target_bucket
  logging_target_prefix = each.value.logging_target_prefix

  acceleration_status = each.value.acceleration_status

  object_lock_enabled = each.value.object_lock_enabled
  object_lock_mode    = each.value.object_lock_mode
  object_lock_days    = each.value.object_lock_days
  object_lock_years   = each.value.object_lock_years

  cors_rules = each.value.cors_rules

  acl      = each.value.acl
  grants   = each.value.grants
  owner_id = each.value.owner_id

  website_enabled                  = each.value.website_enabled
  website_index_document           = each.value.website_index_document
  website_error_document           = each.value.website_error_document
  website_redirect_all_requests_to = each.value.website_redirect_all_requests_to

  lifecycle_enabled                  = each.value.lifecycle_enabled
  lifecycle_expiration_days          = each.value.lifecycle_expiration_days
  noncurrent_version_expiration_days = each.value.noncurrent_version_expiration_days

  bucket_policy = each.value.bucket_policy
}
