/******************************************
  AWS EC2 Image Builder Root Module
 *****************************************/

module "eib" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/eib?ref=v0.9.3"
  for_each = var.eib

  name                          = coalesce(each.value.name, each.key)
  description                   = each.value.description
  parent_image                  = each.value.parent_image
  recipe_version                = each.value.recipe_version
  components                    = each.value.components
  instance_types                = each.value.instance_types
  instance_profile_name         = each.value.instance_profile_name
  subnet_id                     = each.value.subnet_id
  security_group_ids            = each.value.security_group_ids
  key_pair                      = each.value.key_pair
  terminate_instance_on_failure = each.value.terminate_instance_on_failure
  sns_topic_arn                 = each.value.sns_topic_arn
  schedule_expression           = each.value.schedule_expression
  pipeline_status               = each.value.pipeline_status
  tags                          = each.value.tags

  block_device_mappings       = each.value.block_device_mappings
  http_tokens                 = each.value.http_tokens
  http_put_response_hop_limit = each.value.http_put_response_hop_limit
  logging_s3_bucket_name      = each.value.logging_s3_bucket_name
  logging_s3_key_prefix       = each.value.logging_s3_key_prefix
  distributions               = each.value.distributions
}
