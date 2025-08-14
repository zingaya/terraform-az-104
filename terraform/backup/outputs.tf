output "vault_name" {
  description = "Name of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.example.name
}

output "policy_id" {
  description = "ID of the VM Backup Policy"
  value       = azurerm_backup_policy_vm.example.id
}
