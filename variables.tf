########################################################################
################################# General ##############################
variable "subscription" { 
  type = string
  default = ""
}

variable "resourceGroupName" {
  type        = string
  default     = "RG"
  description = "Resource Group Name"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Location where all resources will be deployed"
}

########################################################################
########################### Virtual Networks ###########################
variable "virtualNetworkName" {
  type        = string
  default     = "vnet01"
  description = "Virtual Network Name"
}

variable "virtualNetworkCIDR" {
  type        = list(any)
  default     = ["10.0.0.0/16"]
  description = "VNet IP Address Range"
}

variable "subnets" {
  type = list(object({
    subnetName = string
    subnetCIDR = string
  }))

  # Please follow this order --> Web, Application & DB while defining subnet IP ranges.
  default = [
    {
      subnetName = "webSubnet",
      subnetCIDR = "10.0.1.0/24"
    },
    {
      subnetName = "applicationSubnet",
      subnetCIDR = "10.0.2.0/24"
    },
    {
      subnetName = "dbSubnet",
      subnetCIDR = "10.0.3.0/24"
    }
  ]
}

########################################################################
##################### External Load Balancer - Web #####################
variable "webLoadBalancerName" {
  type    = string
  default = "frontEndLoadBalancer"
}

################### Internal Load Balancer - Application #################
variable "appLoadBalancerName" {
  type    = string
  default = "applicationLoadBalancer"
}

################### Internal Load Balancer - DataBase #################
variable "dbLoadBalancerName" {
  type    = string
  default = "dbLoadBalancer"
}

########################################################################
#################### Virtual Machine - General #########################

variable "VMUserName" {
  type = string
  sensitive = true
  default = "DemoUser"
}

variable "VMPassword" {
  type = string
  sensitive = true
  default = "P@ssw0rd@1"  # For Demo only. In production pass through .tfvars file or through command line.
}

#################### Virtual Machine - Web Tier ########################
variable "webVMCount" {
  type = number
  default = 3
}

################# Virtual Machine - Application Tier####################
variable "appVMCount" {
  type = number
  default = 2
}

#Add-WindowsFeature Web-Server 
#Get-ChildItem "C:\inetpub\wwwroot" -recurse
#Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value $($env:computername)

