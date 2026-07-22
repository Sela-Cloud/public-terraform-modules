resource "google_compute_network" "this" {
  for_each                        = var.vpc_network
  project                         = var.project_id
  name                            = each.value.name
  description                     = each.value.description
  auto_create_subnetworks         = each.value.auto_create_subnetworks
  routing_mode                    = each.value.routing_mode
  mtu                             = each.value.mtu
  delete_default_routes_on_create = each.value.delete_default_routes_on_create
}
