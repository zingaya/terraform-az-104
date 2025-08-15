######################################
# RECOVERY SERVICES VAULT
######################################
resource "azurerm_recovery_services_vault" "example" {
  name                = "${var.backup_name}-vault"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"

  public_network_access_enabled = false

  soft_delete_enabled = false

  tags = {
    environment = "${terraform.workspace}"
  }
}

######################################
# BACKUP POLICY for Virtual Machines
######################################
resource "azurerm_backup_policy_vm" "example" {
  name                = "${var.backup_name}-policy"
  resource_group_name = var.rg_name
  recovery_vault_name = azurerm_recovery_services_vault.example.name
  timezone            = "UTC"  # Schedule timezone for backups

  backup {
    frequency = "Daily"       # Take backup every day
    time      = "23:00"       # At 11 PM UTC, off-peak hours
  }

  retention_daily {
    count = 7                # Keep daily backups for 7 days (7 restore points)
  }

  retention_weekly {
    count    = 2             # Keep weekly backups for 2 weeks (2 restore points)
    weekdays = ["Sunday"]    # Weekly retention applies to Sunday backups only

    # Note: Weekly retention does NOT create new backups.
    # It extends retention time of the Sunday daily backup to 2 weeks instead of 7 days.
  }

  # Total restore points retained at any time:
  # 7 daily backups (one per day)
  # + 2 weekly backups (Sunday backups kept longer)
  # = 9 restore points maximum stored in the vault
}
