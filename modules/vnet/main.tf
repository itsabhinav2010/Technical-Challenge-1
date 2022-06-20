resource "azurerm_virtual_network" "vnet" {
  name                = var.virtualNetworkName
  location            = var.location
  resource_group_name = var.rg
  address_space       = var.virtualNetworkCIDR

  # Creating multiple subnets dynamically
  dynamic "subnet" {
    for_each = var.subnets

    content {
      name           = subnet.value["subnetName"]
      address_prefix = subnet.value["subnetCIDR"]
    }
  }

  ######## EARLIER APPROCH  ########
  # # Web Subnet
  # subnet {
  #   name           = var.webSubnetName
  #   address_prefix = var.webSubnetCIDR
  # }

  # # App Subnet
  # subnet {
  #   name           = var.applicationSubnetName
  #   address_prefix = var.applicationSubnetCIDR
  # }

  # # Database Subnet
  # subnet {
  #   name           = var.dbSubnetName
  #   address_prefix = var.dbSubnetCIDR
  # }
}