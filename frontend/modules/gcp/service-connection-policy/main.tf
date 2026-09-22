module "service_connection_policy" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/service-connection-policy?ref=v0.7.7"
  for_each = var.service_connection_policy

  project_id           = var.project_id
  name                 = each.value.name
  location             = each.value.location
  network              = each.value.network
  description          = each.value.description
  labels               = each.value.labels
  service_class        = each.value.service_class
  subnetworks          = each.value.subnetworks
  psc_connection_limit = each.value.psc_connection_limit
}
