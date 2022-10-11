terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
 
}


data "azurerm_resource_group" "rahulrgname" {
  name = "Devops_kochi"
}


resource "azurerm_storage_account" "storageccountname" {
  name                     = "rahulDevopsstorageaccount"
  resource_group_name      = data.azurerm_resource_group.rahulrgname.name  
  location                 = data.azurerm_resource_group.rahulrgname.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }  

}

resource "azurerm_storage_container" "storagecontainer" {
  name                  = "rahuldatacontainer"
  storage_account_name  = azurerm_storage_account.storageccountname.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.storageccountname
  ]
}