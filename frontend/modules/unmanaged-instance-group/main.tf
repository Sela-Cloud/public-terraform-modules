/******************************************
  Details of the Unmanaged Instance Group
 *****************************************/

module "unmanaged_instance_group" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/unmanaged-instance-group?ref=v0.6.23"
  for_each = var.unmanaged_instance_group

  project_id  = var.project_id
  name        = each.value.name
  description = each.value.description
  zone        = each.value.zone
  network     = each.value.network
  instances   = each.value.instances
  named_ports = each.value.named_ports
}
