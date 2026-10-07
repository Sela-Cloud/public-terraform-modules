/******************************************
  AWS Launch Template Root Module
 *****************************************/

module "lt" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/lt?ref=v0.8.13"
  for_each = var.lt

  name                        = coalesce(each.value.name, each.key)
  name_prefix                 = each.value.name_prefix
  description                 = each.value.description
  image_id                    = each.value.image_id
  instance_type               = each.value.instance_type
  key_name                    = each.value.key_name
  user_data                   = each.value.user_data
  ebs_optimized               = each.value.ebs_optimized
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  update_default_version      = each.value.update_default_version
  iam_instance_profile_name   = each.value.iam_instance_profile_name
  iam_instance_profile_arn    = each.value.iam_instance_profile_arn
  enable_monitoring           = each.value.enable_monitoring
  enable_metadata_options     = each.value.enable_metadata_options
  http_endpoint               = each.value.http_endpoint
  http_tokens                 = each.value.http_tokens
  http_put_response_hop_limit = each.value.http_put_response_hop_limit
  instance_metadata_tags      = each.value.instance_metadata_tags
  block_device_mappings       = each.value.block_device_mappings
  network_interfaces          = each.value.network_interfaces
  tag_specifications          = each.value.tag_specifications
  tags                        = each.value.tags
}
