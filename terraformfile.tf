
provider "azurerm" {
   version = "2.0.0"
   skip_provider_registration="true"
   features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "Devops_Kochi"
    storage_account_name = "rahulstorageaccount02"
    container_name       = "blobecontainer4"
    key                  = "terraform.tfstate"
  }
}


#Resource group
data "azurerm_resource_group" "rahulrg" {
  name = "Devops_Kochi"
}

#Appservice plan for web app 1
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

#web App 1
resource "azurerm_app_service" "rahulappservice" {
  name                = "rahultestwebapp04"
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

# ACR
resource "azurerm_container_registry" "rahulacr" {
  name                = "rahultestwebapp04acr"
  resource_group_name = data.azurerm_resource_group.rahulrg.name
  location            = data.azurerm_resource_group.rahulrg.location
  sku                 = "Standard" 
  admin_enabled       = true
}

# Service plan for web app 2
resource "azurerm_app_service_plan" "service-plan" {
  name = "rahul-appserviceplan-2"
  location = data.azurerm_resource_group.rahulrg.location
  resource_group_name = data.azurerm_resource_group.rahulrg.name
  kind = "Linux"
  reserved = true  
  sku {
    tier = "Standard"
    size = "S1"
  }  
}


# web App 2
resource "azurerm_app_service" "app-service" {
  name = "rahultestwebapp08"
  location = data.azurerm_resource_group.rahulrg.location
  resource_group_name = data.azurerm_resource_group.rahulrg.name
  app_service_plan_id = azurerm_app_service_plan.service-plan.id
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    
    # Settings for private Container Registires  
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.rahulacr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.rahulacr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.rahulacr.admin_password
  
  }
  # Configure Docker Image to load on start
  site_config {
    linux_fx_version = "DOCKER|rahultestwebapp04acr.azurecr.io/demo:latest"
    always_on        = "true"
  }
  identity {
    type = "SystemAssigned"
  }
}

## Outputs
output "app_service_name" {
  value = "${azurerm_app_service.app-service.name}"
}
output "app_service_default_hostname" {
  value = "https://${azurerm_app_service.app-service.default_site_hostname}"
}


