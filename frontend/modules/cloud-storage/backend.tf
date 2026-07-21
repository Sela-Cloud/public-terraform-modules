terraform {
  backend "gcs" {
    bucket = ""
    prefix = "gcp-deployment/terraform/env/prod/global/gcs/"
  }
}
