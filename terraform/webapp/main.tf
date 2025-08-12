######################################
# STATIC WEB APP - lightweight front-end hosting
######################################
resource "azurerm_static_web_app" "staticwebapp" {
  name                = var.static_webapp_name
  resource_group_name = var.rg_name
  location            = var.location

  sku_tier = "Free"   # Free tier suitable for dev/test or small workloads
  sku_size = "Free"
}

######################################
# APP SERVICE PLAN - hosting environment for web app
######################################
resource "azurerm_service_plan" "webapp" {
  name                = "${var.webapp_name}_plan"
  resource_group_name = var.rg_name
  location            = var.location

  os_type  = "Linux"  # Using Linux container for PHP app
  sku_name = "F1"     # Free tier plan to minimize cost (dev/test)
}

######################################
# LINUX WEB APP - actual web app instance
######################################
resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  resource_group_name = var.rg_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.webapp.id

  site_config {
    always_on = false  # Disable Always On to save costs, suitable for dev/test

    application_stack {
      php_version = "8.3"  # Specify PHP version for runtime environment
    }
  }
}
