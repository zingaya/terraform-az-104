######################################
# MINIMAL LINUX VM
######################################
resource "azurerm_linux_virtual_machine" "admin_vm" {
  name                = var.vm_name
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_B1ls" # Cheapest VM size or B1s (free 12 month and 750hs)
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

  # Stop VM after creation to reduce cost, still you'll get charged by the provisioned disk
  provisioner "local-exec" {
    command = "az vm deallocate --resource-group ${var.rg_name} --name ${var.vm_name}"
  }
}

######################################
# Backup Protection
######################################
resource "azurerm_backup_protected_vm" "vm_backup" {
  resource_group_name = var.rg_name
  recovery_vault_name = var.vault_name      # input variable
  source_vm_id        = azurerm_linux_virtual_machine.admin_vm.id
  backup_policy_id    = var.policy_id       # input variable
}
