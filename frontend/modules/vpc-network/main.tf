module "vpc_network" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/vpc-network?ref=v0.3.3"

  project_id  = var.project_id
  vpc_network = var.vpc_network
}
