terraform {
  backend "azurerm" {
    key = "azure-deployment/terraform/env/prod/regional/manage-identities/terraform.tfstate"
  }
}
