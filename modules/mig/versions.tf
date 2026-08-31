terraform {
  required_version = ">=1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.48, < 8"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.48, < 8"
    }
  }
  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-vm:mig/v12.1.0"
  }
  provider_meta "google-beta" {
    module_name = "blueprints/terraform/terraform-google-vm:mig/v12.1.0"
  }
}