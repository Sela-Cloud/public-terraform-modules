module "application_security_group" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/application-security-group?ref=v0.7.6"
  for_each = var.application_security_group

  name                  = each.value.name
  resource_group_name   = each.value.resource_group_name
  location              = each.value.location
  tags                  = each.value.tags
  network_interface_ids = each.value.network_interface_ids
  timeouts              = each.value.timeouts
}
