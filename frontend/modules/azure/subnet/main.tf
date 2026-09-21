module "subnet" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/subnet?ref=v0.1.0"

  for_each = var.subnet

  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name

  address_prefixes = each.value.address_prefixes

  service_endpoints = each.value.service_endpoints

  service_endpoint_policy_ids =
    each.value.service_endpoint_policy_ids

  private_endpoint_network_policies =
    each.value.private_endpoint_network_policies

  private_link_service_network_policies_enabled =
    each.value.private_link_service_network_policies_enabled

  delegation = each.value.delegation
}