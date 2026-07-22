module "vpn" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/vpn?ref=v0.3.3"

  project_id = var.project_id
  vpn        = var.vpn
}
