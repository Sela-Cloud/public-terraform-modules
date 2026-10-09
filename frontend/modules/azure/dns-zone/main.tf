module "dns_zone" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/dns-zone?ref=v0.9.4"
  for_each = var.dns_zone

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  soa_record          = each.value.soa_record
  tags                = each.value.tags
}
