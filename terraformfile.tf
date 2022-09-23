
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

resource "azurerm_network_security_group" "nsg" {
  name                = "example-security-group"
  location            = azurerm_resource_group.rahulrgname.location
  resource_group_name = azurerm_resource_group.rahulrgname.name
  depends_on = [
    azurerm_resource_group.rahulrgname
  ]
}

resource "azurerm_virtual_network" "VirtualNetwork" {
  name                = "example-network"
  location            = azurerm_resource_group.rahulrgname.location
  resource_group_name = azurerm_resource_group.rahulrgname.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.nsg.id
  }

  tags = {
    environment = "staging"
  }
  depends_on = [
    azurerm_network_security_group.nsg
  ]
}