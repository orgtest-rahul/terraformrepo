
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


locals {
  resource_group_name="rah-rg1"
  resource_group_location="North Europe"
  virtual_network={
    name ="ra-virtual-network"
    address_space = ["10.0.0.0/16"]
    dns_servers = ["10.0.0.4", "10.0.0.5"]
  }

  subnets=[
    {
      name="subnet1"
      address_prefix = "10.0.1.0/24"
    },
    {
      name           = "subnet2"
      address_prefix = "10.0.2.0/24"
    }
  ]

}

resource "azurerm_resource_group" "rahulrgname" {
  name     = local.resource_group_name
  location = local.resource_group_location
}

resource "azurerm_network_security_group" "nsg" {
  name                = "ra-network-security-group"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  depends_on = [
    azurerm_resource_group.rahulrgname
  ]
}

resource "azurerm_virtual_network" "VirtualNetwork" {
  name                = local.virtual_network.name
  location            = azurerm_resource_group.rahulrgname.location
  resource_group_name = azurerm_resource_group.rahulrgname.name
  address_space       = local.virtual_network.address_space
  dns_servers         = local.virtual_network.dns_servers

  subnet {
    name           = local.subnets[0].name
    address_prefix = local.subnets[0].address_prefix
  }

  subnet {
    name           = local.subnets[1].name
    address_prefix = local.subnets[1].address_prefix
    security_group = azurerm_network_security_group.nsg.id
  }

  tags = {
    environment = "staging"
  }
  depends_on = [
    azurerm_network_security_group.nsg
  ]
}

# resource "azurerm_network_interface" "appnetworkinterface" {
#   name                = "appnetworkinterface"
#   location            = local.resource_group_location
#   resource_group_name = local.resource_group_name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.local.subnets[1].name.id
#     private_ip_address_allocation = "Dynamic"
#   }

#     depends_on = [
#     azurerm_virtual_network.VirtualNetwork
#   ]

# }