
provider "azurerm" {
  skip_provider_registration = "true"
  version = "~>2.0"  
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
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
    java_version           = "11"
    linux_fx_version = "TOMCAT|9.0-java11"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }


}



