######################################
# CALCULATE A DYNAMIC EXPIRY DATE
######################################
locals {
  start_date = timeadd(timestamp(), "240h") # Future start
  expiry_date = timeadd(local.start_date, "168h") # Expiry 7 days after
}

######################################
# GIVE SAS ACCESS TO STORAGE ACCOUNT
######################################
data "azurerm_storage_account_sas" "account_sas" {
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
# Get it later with command: terraform output sas_url
output "sas_token" {
  value = data.azurerm_storage_account_sas.account_sas.sas
  sensitive = true
}
