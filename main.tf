provider "azurerm" {
  features {}
  subscription_id = var.subscription
}

locals {
  webVMSufix = "web"
  appVMSufix = "app"
  dbVMSufix  = "db"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location
}

# Create Virtual Network and Subnet for 3 tiers
module "network" {
  source   = "./modules/vnet"
  rg       = var.resourceGroupName
  location = var.location

  virtualNetworkName = var.virtualNetworkName
  virtualNetworkCIDR = var.virtualNetworkCIDR

  subnets = var.subnets

  depends_on = [
    azurerm_resource_group.rg
  ]
}

#### Web Tier VMs #######
module "WebVM" { 
  source = "./modules/compute"
  rg       = var.resourceGroupName
  location = var.location

  vmType   = local.webVMSufix
  vmCount  = var.webVMCount
  subnetId = module.network.virtualNetwork.allSubnets[0]

  username = var.VMUserName
  password = var.VMPassword

  depends_on = [
    module.network
  ]
}

#### Application Tier VMs #######
module "ApplicationVM" { 
  source = "./modules/compute"
  rg       = var.resourceGroupName
  location = var.location

  vmType   = local.appVMSufix
  vmCount  = var.appVMCount
  subnetId = module.network.virtualNetwork.allSubnets[1]

  username = var.VMUserName
  password = var.VMPassword

  depends_on = [
    module.network
  ]
}

# External Load Balancer - WEB
module "webExternalLoadBalancer" {
  source   = "./modules/externalLoadBalancer"
  rg       = var.resourceGroupName
  location = var.location

  azureLoadBalancerName = var.webLoadBalancerName

  vnetId = module.network.virtualNetwork.vnetId
  backEndPoolIPs = module.WebVM.VMIPs

  depends_on = [
    module.network,
    module.WebVM
  ]
}

#Internal Load Balancer - APPLICATION
module "appInternalLoadBalancer" {
  source   = "./modules/internalLoadBalancer"
  rg       = var.resourceGroupName
  location = var.location

  azureLoadBalancerName = var.appLoadBalancerName

  vnetId = module.network.virtualNetwork.vnetId
  subnetId = module.network.virtualNetwork.allSubnets[1]
  backEndPoolIPs = module.ApplicationVM.VMIPs

  depends_on = [
    module.network,
    module.ApplicationVM
  ]
}

### #Internal Load Balancer - Database (NOT PROVISIONED)
# module "dbInternalLoadBalancer" {
#   source   = "./modules/internalLoadBalancer"
#   rg       = var.resourceGroupName
#   location = var.location

#   azureLoadBalancerName = var.dbLoadBalancerName

#   vnetId = module.network.virtualNetwork.vnetId
#   subnetId = module.network.virtualNetwork.allSubnets[1]
#   backEndPoolIPs = module.ApplicationVM.VMIPs

#   depends_on = [
#     module.network,
#     module.DataBase
#   ]
# }

output "test" {
  value = {
    vnet    = module.network.virtualNetwork.vnetId
    allSubnets = module.network.virtualNetwork.allSubnets
    webVMIPs   = module.WebVM.VMIPs
    appVMIPs   = module.ApplicationVM.VMIPs
  }
}

############

