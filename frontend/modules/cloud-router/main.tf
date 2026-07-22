module "cloud_router" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-router?ref=v0.3.3"

  project_id   = var.project_id
  cloud_router = var.cloud_router
}
