output "VMIPs" {
  value = azurerm_network_interface.nic[*].private_ip_address # For load balancer backend pool
}