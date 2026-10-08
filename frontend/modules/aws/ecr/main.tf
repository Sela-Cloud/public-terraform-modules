/******************************************
  AWS ECR Repository Root Module
 *****************************************/

module "ecr" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/ecr?ref=v0.9.4"
  for_each = var.ecr

  name                 = coalesce(each.value.name, each.key)
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete
  scan_on_push         = each.value.scan_on_push
  encryption_type      = each.value.encryption_type
  kms_key              = each.value.kms_key
  tags                 = each.value.tags
  lifecycle_policy     = each.value.lifecycle_policy
  repository_policy    = each.value.repository_policy
}
