terraform {
  backend "gcs" {
    bucket = "boxpay-prod-tf-state-asia-south2"
    prefix = "gcp-deployment/terraform/env/prod/global/gcs/"
  }
}
