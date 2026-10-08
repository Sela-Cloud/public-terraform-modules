module "dns_a_record" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/dns-a-record?ref=v0.9.4"
  for_each = var.dns_a_record

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  zone_name           = each.value.zone_name
  ttl                 = each.value.ttl
  records             = each.value.records
  target_resource_id  = each.value.target_resource_id
  tags                = each.value.tags
}
