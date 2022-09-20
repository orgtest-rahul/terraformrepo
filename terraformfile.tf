
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

  subscription_id = "da62005e-ffbb-483c-8af3-929e423ed9ce"
  client_id       = "2722272e-a7c2-4475-bfe5-157ae43ac7c3"
  client_secret   = "D_a8Q~9LYmKvCUFzRd4.JiUSmaJQGWfKIDIkNciK"
  tenant_id       = "bd5c6713-7399-4b31-be79-78f2d078e543"
}



resource "azurerm_resource_group" "rahulrgname" {
  name     = "rah-rg1"
  location = "North Europe"
}


resource "azurerm_storage_account" "storageccountname" {
  name                     = "storageaccountra"
  resource_group_name      =  azurerm_resource_group.rahulrgname.name  
  location                 = azurerm_resource_group.rahulrgname.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "storagecontainer" {
  name                  = "radatacontainer"
  storage_account_name  = azurerm_storage_account.storageccountname.name
  container_access_type = "blob"
}


resource "azurerm_storage_blob" "maintf" {
  name                   = "readme"
  storage_account_name   = azurerm_storage_account.storageccountname.name
  storage_container_name = azurerm_storage_container.storagecontainer.name
  type                   = "Block"
  source                 = "readme.md"
}
