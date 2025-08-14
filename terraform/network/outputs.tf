output "acisubnet" {
  value = azurerm_subnet.main2.id
}

output "adminsubnet" {
  value = azurerm_subnet.main1.id
}

