module "firewall" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/firewall?ref=v0.3.3"

  project_id = var.project_id
  firewall   = var.firewall
}
