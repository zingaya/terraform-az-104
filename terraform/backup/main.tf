resource "azurerm_resource_group" "example" {
  name     = "rg-backup"
  location = "eastus"
}

resource "azurerm_recovery_services_vault" "example" {
  name                = "example-vault"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "example" {
  name                = "example-policy"
  resource_group_name = azurerm_resource_group.example.name
  recovery_vault_name = azurerm_recovery_services_vault.example.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }

  retention_weekly {
    count          = 2
    weekdays       = ["Sunday"]
  }
}
