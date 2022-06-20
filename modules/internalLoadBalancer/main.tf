################# INTERNAL LOAD BALANCER  #####################
resource "azurerm_lb" "internalLoadBalancer" {
  name                = var.azureLoadBalancerName
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontendConfig"
    subnet_id = var.subnetId
    private_ip_address_version = "IPv4"
  }
}

resource "azurerm_lb_backend_address_pool" "lbBackendAddressPool" {
  loadbalancer_id     = azurerm_lb.internalLoadBalancer.id
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
  loadbalancer_id = azurerm_lb.internalLoadBalancer.id
  name            = "health-probe"
  port            = 80
}

resource "azurerm_lb_rule" "lbRule" {
  loadbalancer_id                = azurerm_lb.internalLoadBalancer.id
  name                           = "DefaultRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontendConfig"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lbBackendAddressPool.id]
  probe_id = azurerm_lb_probe.probe.id
}
