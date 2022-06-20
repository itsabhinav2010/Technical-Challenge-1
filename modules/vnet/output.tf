output "virtualNetwork" {
  value = { 
    vnetId = azurerm_virtual_network.vnet.id
    allSubnets = azurerm_virtual_network.vnet.subnet[*].id
  }
}