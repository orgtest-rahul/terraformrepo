locals {
  resource_group_name="Devops_kochi"  
  resource_group_location="West Europe"
}

# resource "azurerm_resource_group" "rahulrgname" {
#   name     = local.resource_group_name
#   location = local.resource_group_location
# }


data "azurerm_resource_group" "rahulrgname" {
  name = local.resource_group_name
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "rahulstoraccount"
  resource_group_name      = azurerm_resource_group.rahulrgname.name
  location                 = azurerm_resource_group.rahulrgname.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "container" {
  for_each = toset(["data","files","documents"])
  name                  = each.key
  storage_account_name  = azurerm_storage_account.storageaccount.name
  container_access_type = "blob"
}
