module "bastion_host" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/bastion-host?ref=v0.7.6"
  for_each = var.bastion_host

  name                      = each.value.name
  resource_group_name       = each.value.resource_group_name
  location                  = each.value.location
  ip_configuration          = each.value.ip_configuration
  sku                       = each.value.sku
  scale_units               = each.value.scale_units
  copy_paste_enabled        = each.value.copy_paste_enabled
  file_copy_enabled         = each.value.file_copy_enabled
  shareable_link_enabled    = each.value.shareable_link_enabled
  tunneling_enabled         = each.value.tunneling_enabled
  ip_connect_enabled        = each.value.ip_connect_enabled
  session_recording_enabled = each.value.session_recording_enabled
  kerberos_enabled          = each.value.kerberos_enabled
  zones                     = each.value.zones
  tags                      = each.value.tags
}
