module "subnet" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/subnet?ref=v0.3.3"

  project_id = var.project_id
  subnet     = var.subnet
}
