########## EXTERNAL LOAD BALANCER WITH PUBLIC IP ##############
resource "azurerm_public_ip" "pip1" {
  name                = "externalLBPublicIP"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "externalloadBalancer" {
  name                = var.azureLoadBalancerName
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontendIPConfig"
    public_ip_address_id = azurerm_public_ip.pip1.id
  }
}

resource "azurerm_lb_backend_address_pool" "lbBackendAddressPool" {
  loadbalancer_id     = azurerm_lb.externalloadBalancer.id
  name                = "backEndAddressPool"
}

resource "azurerm_lb_backend_address_pool_address" "lbBackendAddressPoolAddress" {
  count                   = length(var.backEndPoolIPs)
  name                    = "backEndAddressPoolAddress-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbBackendAddressPool.id
  virtual_network_id      = var.vnetId
  ip_address              = var.backEndPoolIPs[count.index]

  depends_on = [
    azurerm_lb_backend_address_pool.lbBackendAddressPool
  ]
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.externalloadBalancer.id
  name            = "health-probe"
  port            = 80
}

resource "azurerm_lb_rule" "lbRule" {
  loadbalancer_id                = azurerm_lb.externalloadBalancer.id
  name                           = "DefaultRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontendIPConfig"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lbBackendAddressPool.id]
  probe_id = azurerm_lb_probe.probe.id
}
