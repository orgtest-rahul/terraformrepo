resource "azurerm_network_interface" "appnetworkinterface" {
  count = var.number_of_Vms
  name                = "rahulappnetworkinterface${count.index}"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.appip[count.index].id
  }

    depends_on = [
    azurerm_subnet.subnets,
    azurerm_public_ip.appip
  ]

}

# Output the id
output "subnetA-ID" {
  
  value = azurerm_subnet.subnetA.id

}

resource "azurerm_public_ip" "appip" {
  count = var.number_of_Vms
  name                = "rahulTestPublicIp${count.index}"
  resource_group_name = local.resource_group_name 
  location            = local.resource_group_location
  allocation_method   = "Static"

  tags = {
    environment = "staging"
  }

}
