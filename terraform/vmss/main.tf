######################################
# VIRTUAL MACHINE SCALE SET - LINUX VM
######################################
resource "azurerm_linux_virtual_machine_scale_set" "admin_vmss" {
  name                = var.vmss_name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Standard_B1ls"  # Cheapest VM size
  instances           = 0

  # Multi-zone deployment: specify the zones if you want VMs spread across different datacenters
  zones = ["1", "2", "3"]  # Azure will automatically handle fault domains within each zone
  # platform_fault_domain_count = 5

  # Admin credentials
  admin_username      = "azureuser"
  admin_ssh_key {
    username          = "azureuser"
    public_key        = file(var.ssh_publickey)
  }
  disable_password_authentication = true

  # OS disk configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Linux image to use
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Network interface configuration
  network_interface {
    name    = "${var.vmss_name}-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.adminsubnet
    }
  }
}
