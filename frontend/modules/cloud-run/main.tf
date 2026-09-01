module "cloud_run_v2" {
  source                           = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-run?ref=v0.6.18"
  for_each                         = var.cloud_run
  project_id                       = var.project_id
  service_name                     = each.value.service_name
  location                         = each.value.location
  service_account                  = each.value.service_account
  service_labels                   = each.value.service_labels
  cloud_run_deletion_protection    = each.value.cloud_run_deletion_protection
  containers                       = each.value.containers
  ingress                          = each.value.ingress
  volumes                          = each.value.volumes
  vpc_access                       = each.value.vpc_access
  max_instance_request_concurrency = each.value.max_instance_request_concurrency
  template_scaling                 = each.value.scaling
  template_annotations             = each.value.template_annotations
}
