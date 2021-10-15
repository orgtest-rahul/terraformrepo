
provider "azurerm" {
   version = "2.0.0"
   skip_provider_registration="true"
   features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "Devops_Kochi"
    storage_account_name = "rahul1storageaccount"
    container_name       = "blobcontainer"
    key                  = "terraform.tfstate"
  }
}

data "azurerm_resource_group" "rahulrg" {
  name = "Devops_Kochi"
}

resource "azurerm_app_service_plan" "rahulappserviceplan" {
  name                = "rahul-appserviceplan-1"
  location            = data.azurerm_resource_group.rahulrg.location
  resource_group_name = data.azurerm_resource_group.rahulrg.name
  kind                = "Linux"
  reserved            = "true"
  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_app_service" "rahulappservice" {
  name                = "rahul-app-service-1"
  location            = data.azurerm_resource_group.rahulrg.location
  resource_group_name = data.azurerm_resource_group.rahulrg.name
  app_service_plan_id = azurerm_app_service_plan.rahulappserviceplan.id

  site_config {
    scm_type                 = "LocalGit"
    linux_fx_version         = "TOMCAT|9.0-java11"
    
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }


}



