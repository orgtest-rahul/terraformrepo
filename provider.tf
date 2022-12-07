terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.30.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}  
}

terraform {
  backend "azurerm" {
    resource_group_name  = "Devops_kochi"
    storage_account_name = "rahuldevstorageaccount"
    container_name       = "rahuldatacontainer"
    key                  = "stage.terraform.tfstate"
  }
}