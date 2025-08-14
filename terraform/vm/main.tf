######################################
# MINIMAL LINUX VM
######################################
# Local variable to enable or disable the container group creation
# Optional, may incur costs

resource "azurerm_linux_virtual_machine" "admin_vm" {
  name                = "vm-admin1"
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_B1ls"  # Cheapest VM size
  zone                = "2" # Only Zone 2 and Zone 3 is available for this VM size

  admin_username      = "azureuser"
  admin_ssh_key {
    username          = "azureuser"
    public_key        = file(var.ssh_publickey)
  }
  disable_password_authentication = true

  network_interface_ids = [var.adminnic]  # Assign the NIC created earlier

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Stop VM after creation to reduce cost
  provisioner "local-exec" {
    command = "az vm deallocate --resource-group ${var.rg_name} --name vm-admin1"
  }
}

######################################
# Notes if you don't have a NIC already
######################################
# If you didn't pre-create a NIC, you could use this instead:
# 
# network_interface {
#   name                          = "admin2"
#   subnet_id                     = adminsubnet
#   private_ip_address_allocation = "Dynamic"
# }
#
# Terraform would create the NIC automatically as part of the VM, 
# but you wouldn't have a separate resource to reference in other modules.

######################################
# Backup Protection
######################################
resource "azurerm_backup_protected_vm" "vm_backup" {
  resource_group_name = var.rg_name
  recovery_vault_name = var.vault_name      # input variable
  source_vm_id        = azurerm_linux_virtual_machine.admin_vm.id
  backup_policy_id    = var.policy_id       # input variable
}
