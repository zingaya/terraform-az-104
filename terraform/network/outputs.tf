output "acisubnet" {
  value = azurerm_subnet.main2.id
}

output "adminsubnet" {
  value = azurerm_subnet.main1.id
}

output "adminnic" {
  value = azurerm_network_interface.nic["admin1"].id
}
