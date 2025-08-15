output "static_webapp_host" {
  value = azurerm_static_web_app.staticwebapp.default_host_name
}

output "static_webapp_token" {
  value = azurerm_static_web_app.staticwebapp.repository_token
}
