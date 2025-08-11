resource "azurerm_static_web_app" "staticwebapp" {
  name = var.static_webapp_name
  resource_group_name = var.rg_name
  location = var.location

  sku_tier = "Free"
  sku_size = "Free"
}

resource "azurerm_service_plan" "webapp" {
  name = "${var.webapp_name}_plan"
  resource_group_name = var.rg_name
  location = var.location

  os_type = "Linux"
  sku_name = "F1"
}

resource "azurerm_linux_web_app" "webapp" {
  name = var.webapp_name
  resource_group_name = var.rg_name
  location = var.location
  service_plan_id = azurerm_service_plan.webapp.id

  site_config {
    always_on = false

    application_stack {
      php_version = "8.3"
    }
  }
}
