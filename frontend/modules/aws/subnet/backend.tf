terraform {
  backend "s3" {
    bucket = ""
    key    = "aws-deployment/terraform/env/prod/regions/us-east-1/subnet/terraform.tfstate"
    region = "us-east-1"
  }
}
