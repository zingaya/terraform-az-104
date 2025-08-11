# Storage Account
resource "azurerm_storage_account" "main" {
  name = var.storage_account_name
  resource_group_name = var.rg_name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"

  allow_nested_items_to_be_public = false
  min_tls_version = "TLS1_2"

  network_rules {
    default_action = length(var.public_ip) == 0 ? "Allow" : "Deny"
    ip_rules = length(var.public_ip) == 0 ? [] : var.public_ip
  }

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "main" {
  count = 0
  name = "labtable"
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_queue" "main" {
  count = 0
  name = "lab-queue"
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_share" "main" {
  count = 0
  name = "lab-share"
  storage_account_id = azurerm_storage_account.main.id
  quota = 1 # Gigabytes
}

resource "azurerm_storage_container" "main" {
  count = 0
  name = "lab-container"
  storage_account_id = azurerm_storage_account.main.id
  container_access_type = "private"
}

#resource "azurerm_storage_blob" "main" {
#  count = 0
#  name = "lab-blob"
#  storage_account_name = azurerm_storage_account.main.name
#  storage_container_name = azurerm_storage_container.main.name
#  type = "Block"
#  source = "blob.txt"
#}
