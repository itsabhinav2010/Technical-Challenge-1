resource "azurerm_network_interface" "nic" {
  count               = var.vmCount
  name                = "nic-${var.vmType}-${count.index}" #
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnetId
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.vmCount

  name                = "${var.vmType}-vm-${count.index}"
  resource_group_name = var.rg
  location            = var.location
  size                = "Standard_B4ms"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}