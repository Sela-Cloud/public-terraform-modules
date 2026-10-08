/******************************************
  Route 53 Record Root Module
 *****************************************/

module "route53_record" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/route53-record?ref=v0.9.3"
  for_each = var.route53_record

  zone_id                       = each.value.zone_id
  name                          = each.value.name
  type                          = each.value.type
  is_alias                      = each.value.is_alias
  alias_name                    = each.value.alias_name
  alias_zone_id                 = each.value.alias_zone_id
  alias_evaluate_target_health  = each.value.alias_evaluate_target_health
  ttl                           = each.value.ttl
  records                       = each.value.records
  routing_policy_type           = each.value.routing_policy_type
  set_identifier                = each.value.set_identifier
  health_check_id               = each.value.health_check_id
  weighted_weight               = each.value.weighted_weight
  latency_region                = each.value.latency_region
  failover_type                 = each.value.failover_type
  geolocation_continent         = each.value.geolocation_continent
  geolocation_country           = each.value.geolocation_country
  geolocation_subdivision       = each.value.geolocation_subdivision
  geoproximity_aws_region       = each.value.geoproximity_aws_region
  geoproximity_bias             = each.value.geoproximity_bias
  geoproximity_local_zone_group = each.value.geoproximity_local_zone_group
  geoproximity_latitude         = each.value.geoproximity_latitude
  geoproximity_longitude        = each.value.geoproximity_longitude
  cidr_collection_id            = each.value.cidr_collection_id
  cidr_location_name            = each.value.cidr_location_name
  allow_overwrite               = each.value.allow_overwrite
}
