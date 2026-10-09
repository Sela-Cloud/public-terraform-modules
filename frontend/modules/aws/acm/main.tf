/******************************************
  AWS ACM Certificate Root Module
 *****************************************/

module "acm" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/acm?ref=v0.8.13"
  for_each = var.acm

  name                      = coalesce(each.value.name, each.key)
  domain_name               = each.value.domain_name
  validation_method         = each.value.validation_method
  subject_alternative_names = each.value.subject_alternative_names
  key_algorithm             = each.value.key_algorithm
  certificate_authority_arn = each.value.certificate_authority_arn
  create_route53_records    = each.value.create_route53_records
  zone_id                   = each.value.zone_id
  validate_certificate      = each.value.validate_certificate
  tags                      = each.value.tags
}
