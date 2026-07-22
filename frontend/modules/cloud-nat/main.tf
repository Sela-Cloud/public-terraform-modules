module "cloud_nat" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-nat?ref=v0.3.3"

  project_id = var.project_id
  cloud_nat  = var.cloud_nat
}
