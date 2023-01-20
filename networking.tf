
data "azurerm_resource_group" "rahulrgname" {
  name = local.resource_group_name
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
 
}

resource "azurerm_subnet" "subnets" {
  count = var.number_of_subnets
  name                 = local.subnets[count.index].name
  resource_group_name  = data.azurerm_resource_group.rahulrgname.name
  virtual_network_name = azurerm_virtual_network.VirtualNetwork.name
  address_prefixes     = [local.subnets[count.index].address_prefix]

  depends_on = [
    azurerm_virtual_network.VirtualNetwork
  ]
}
