######################################
# CALCULATE A DYNAMIC EXPIRY DATE
######################################
locals {
  start_date = timeadd(timestamp(), "24h") # Starts tomorrow
  expiry_date = timeadd(local.start_date, "24h") # Expiry 1 day later
}

######################################
# GIVE SAS ACCESS TO STORAGE ACCOUNT
######################################
data "azurerm_storage_account_sas" "account_sas" {
# For security, just create once, then keep it disabled.
# Otherwise will create this SAS every time you run "terraform apply"
  count             = 0

  connection_string = resource.azurerm_storage_account.main.primary_connection_string
  https_only        = true
  signed_version    = "2022-11-02"

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  ip_addresses = length(var.public_ip) > 0 ? join(",", var.public_ip) : null

  start  = local.start_date
  expiry = local.expiry_date

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

# Output the SAS
# Workaround if "count = 0"
output "sas_token" {
  value = length(data.azurerm_storage_account_sas.account_sas) > 0 ? data.azurerm_storage_account_sas.account_sas[0].sas : null
  sensitive = true
}
