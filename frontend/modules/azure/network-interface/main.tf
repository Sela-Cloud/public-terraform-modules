module "network_interface" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/network-interface?ref=v0.8.9"
  for_each = var.network_interface

  name                           = each.value.name
  resource_group_name            = each.value.resource_group_name
  location                       = each.value.location
  ip_configurations              = each.value.ip_configurations
  dns_servers                    = each.value.dns_servers
  edge_zone                      = each.value.edge_zone
  ip_forwarding_enabled          = each.value.ip_forwarding_enabled
  accelerated_networking_enabled = each.value.accelerated_networking_enabled
  internal_dns_name_label        = each.value.internal_dns_name_label
  network_security_group_id      = each.value.network_security_group_id
  auxiliary_mode                 = each.value.auxiliary_mode
  auxiliary_sku                  = each.value.auxiliary_sku
  tags                           = each.value.tags
}
