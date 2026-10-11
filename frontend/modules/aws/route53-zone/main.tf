/******************************************
  Route 53 Hosted Zone Root Module
 *****************************************/

module "route53_zone" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/route53-zone?ref=v0.9.5"
  for_each = var.route53_zone

  name              = coalesce(each.value.name != "" ? each.value.name : null, each.key)
  comment           = each.value.comment
  force_destroy     = each.value.force_destroy
  delegation_set_id = each.value.delegation_set_id
  vpc_associations  = each.value.vpc_associations
  tags              = each.value.tags
}
