######################################
# MAIN STORAGE ACCOUNT
######################################

# Primary Storage Account
# - Uses var.public_ip (from secrets.tfvars) to restrict access if provided.
# - Defaults to "Allow all" when public_ip list is empty.
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Security hardening
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  # Network rules: Restrict to IP list if provided, else allow all
  network_rules {
    default_action = length(var.public_ip) == 0 ? "Allow" : "Deny"
    ip_rules       = length(var.public_ip) == 0 ? [] : var.public_ip
  }

  tags = {
    environment = "staging"
  }
}

######################################
# OPTIONAL STORAGE RESOURCES
# Use count = 0 to avoid accidental creation and associated costs
######################################

# Azure Table Storage (disabled by default)
resource "azurerm_storage_table" "main" {
  count                = 0
  name                 = "labtable"
  storage_account_name = azurerm_storage_account.main.name
}

# Azure Storage Queue (disabled by default)
resource "azurerm_storage_queue" "main" {
  count                = 0
  name                 = "lab-queue"
  storage_account_name = azurerm_storage_account.main.name
}

# Azure File Share (disabled by default)
resource "azurerm_storage_share" "main" {
  count                 = 0
  name                  = "lab-share"
  storage_account_id    = azurerm_storage_account.main.id
  quota                 = 1 # Size in GiB
}

# Azure Blob Container (disabled by default)
resource "azurerm_storage_container" "main" {
  count                 = 0
  name                  = "lab-container"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# Example Blob (disabled by default)
# Uncomment to enable blob creation and upload
# resource "azurerm_storage_blob" "main" {
#   count                  = 0
#   name                   = "lab-blob"
#   storage_account_name   = azurerm_storage_account.main.name
#   storage_container_name = azurerm_storage_container.main.name
#   type                   = "Block"
#   source                 = "blob.txt"
# }
