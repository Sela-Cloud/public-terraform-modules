module "virtual_machine" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/virtual-machine?ref=v0.7.6"
  for_each = var.virtual_machine

  name                             = each.value.name
  resource_group_name              = each.value.resource_group_name
  location                         = each.value.location
  vm_size                          = each.value.vm_size
  network_interface_ids            = each.value.network_interface_ids
  primary_network_interface_id     = each.value.primary_network_interface_id
  availability_set_id              = each.value.availability_set_id
  zones                            = each.value.zones
  proximity_placement_group_id     = each.value.proximity_placement_group_id
  license_type                     = each.value.license_type
  delete_os_disk_on_termination    = each.value.delete_os_disk_on_termination
  delete_data_disks_on_termination = each.value.delete_data_disks_on_termination
  storage_os_disk                  = each.value.storage_os_disk
  storage_image_reference          = each.value.storage_image_reference
  storage_data_disks               = each.value.storage_data_disks
  os_profile                       = each.value.os_profile
  os_profile_linux_config          = each.value.os_profile_linux_config
  os_profile_windows_config        = each.value.os_profile_windows_config
  identity                         = each.value.identity
  boot_diagnostics                 = each.value.boot_diagnostics
  tags                             = each.value.tags
}
