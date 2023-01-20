locals {
  resource_group_name="Devops_kochi"
  resource_group_location="West Europe"
  virtual_network={
    name ="rahul-virtual-network"
    address_space = ["10.0.0.0/16"]
    dns_servers = ["10.0.0.4", "10.0.0.5"]
  }

}