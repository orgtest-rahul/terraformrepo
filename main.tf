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

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }


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

resource "azurerm_subnet" "subnetA" {
  name                 = local.subnets[0].name
  resource_group_name  = data.azurerm_resource_group.rahulrgname.name
  virtual_network_name = azurerm_virtual_network.VirtualNetwork.name
  address_prefixes     = [local.subnets[0].address_prefix]

  depends_on = [
    azurerm_virtual_network.VirtualNetwork
  ]
}

resource "azurerm_subnet" "subnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = data.azurerm_resource_group.rahulrgname.name
  virtual_network_name = azurerm_virtual_network.VirtualNetwork.name
  address_prefixes     = [local.subnets[1].address_prefix]

  depends_on = [
    azurerm_virtual_network.VirtualNetwork
  ]
}



resource "azurerm_network_interface" "appnetworkinterface" {
  name                = "rahulappnetworkinterface"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.appip.id
  }

    depends_on = [
    azurerm_subnet.subnetA
  ]

}

# Output the id
output "subnetA-ID" {
  
  value = azurerm_subnet.subnetA.id

}

resource "azurerm_public_ip" "appip" {
  name                = "rahulTestPublicIp1"
  resource_group_name = local.resource_group_name 
  location            = local.resource_group_location
  allocation_method   = "Static"

  tags = {
    environment = "staging"
  }

}

resource "azurerm_subnet_network_security_group_association" "rahulnsgassociation" {
  subnet_id                 = azurerm_subnet.subnetA.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_windows_virtual_machine" "rahulvm" {
  name                = "rahulwvd"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  size                = "Standard_D2S_V3"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  network_interface_ids = [
    azurerm_network_interface.appnetworkinterface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.appnetworkinterface
  ]
}

resource "azurerm_managed_disk" "rahuldatadisk" {
  name                 = "rahuldatadisk"
  location             = local.resource_group_location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "diskattachment" {
  managed_disk_id    = azurerm_managed_disk.rahuldatadisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.rahulvm.id
  lun                = "0"
  caching            = "ReadWrite"
}
