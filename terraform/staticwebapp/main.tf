######################################
# STATIC WEB APP - lightweight front-end hosting
######################################
resource "azurerm_static_web_app" "staticwebapp" {
  name                = var.static_webapp_name
  resource_group_name = var.rg_name
  location            = var.location

  lifecycle {
    ignore_changes = [ repository_branch, repository_url ]
  }

  sku_tier = "Free"   # Free tier suitable for dev/test or small workloads
  sku_size = "Free"
}
