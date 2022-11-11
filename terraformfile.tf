
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


locals {
  resource_group_name="Devops_kochi"
  resource_group_location="West Europe"
  virtual_network={
    name ="rahul-virtual-network"
    address_space = ["10.0.0.0/16"]
    dns_servers = ["10.0.0.4", "10.0.0.5"]
  }

  subnets=[
    {
      name="subnetA"
      address_prefix = "10.0.0.0/24"
    },
    {
      name           = "subnetB"
      address_prefix = "10.0.1.0/24"
    }
  ]

}

# resource "azurerm_resource_group" "rahulrgname" {
#   name     = local.resource_group_name
#   location = local.resource_group_location
# }


data "azurerm_resource_group" "rahulrgname" {
  name = local.resource_group_name
}

resource "azurerm_network_security_group" "nsg" {
  name                = "rahul-network-security-group"
  location            = data.azurerm_resource_group.rahulrgname.location
  resource_group_name = data.azurerm_resource_group.rahulrgname.name

}

resource "azurerm_virtual_network" "VirtualNetwork" {
  name                = local.virtual_network.name
  location            = data.azurerm_resource_group.rahulrgname.location
  resource_group_name = data.azurerm_resource_group.rahulrgname.name
  address_space       = local.virtual_network.address_space
  dns_servers         = local.virtual_network.dns_servers

  tags = {
    environment = "staging"
  }
  depends_on = [
    azurerm_network_security_group.nsg
  ]
}



