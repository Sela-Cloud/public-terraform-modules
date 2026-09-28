module "private_endpoint" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/private-endpoint?ref=v0.7.6"
  for_each = var.private_endpoint

  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.custom_network_interface_name
  private_service_connection    = each.value.private_service_connection
  private_dns_zone_group        = each.value.private_dns_zone_group
  ip_configurations             = each.value.ip_configurations
  tags                          = each.value.tags
}
