terraform {
  required_version = ">= 1.6.1"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.8.0"
    }
  }
}
