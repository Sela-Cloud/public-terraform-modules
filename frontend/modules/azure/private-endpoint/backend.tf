terraform {
  backend "azurerm" {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = "azure-deployment/terraform/env/prod/regional/private-endpoint/terraform.tfstate"
  }
}
