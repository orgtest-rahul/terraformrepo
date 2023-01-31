
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
  name                 = "Subnet${count.index}"
  resource_group_name  = data.azurerm_resource_group.rahulrgname.name
  virtual_network_name = azurerm_virtual_network.VirtualNetwork.name
  address_prefixes     = ["10.0.${count.index}.0/24"]

  depends_on = [
    azurerm_virtual_network.VirtualNetwork
  ]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "rahul-network-security-group"
  location            = data.azurerm_resource_group.rahulrgname.location
  resource_group_name = data.azurerm_resource_group.rahulrgname.name
  # For linux VM trafic is allowing through secure shell, not through RDP and its port number is 22
  security_rule {
    name                       = "AllowSSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }

}

resource "azurerm_subnet_network_security_group_association" "rahulnsgassociation" {
  count = var.number_of_subnets
  subnet_id                 = azurerm_subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [
    azurerm_virtual_network.VirtualNetwork,
    azurerm_subnet.subnets
  ]
}

