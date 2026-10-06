/******************************************
  AWS ECR/ACR Repository Root Module
 *****************************************/

module "acr" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/acr?ref=v0.8.8"
  for_each = var.acr

  name                 = coalesce(each.value.name, each.key)
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete
  scan_on_push         = each.value.scan_on_push
  encryption_type      = each.value.encryption_type
  kms_key              = each.value.kms_key
  tags                 = each.value.tags
}
