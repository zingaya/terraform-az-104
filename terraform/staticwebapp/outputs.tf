output "static_webapp_host" {
  value = azurerm_static_web_app.staticwebapp.default_host_name
}


data "external" "static_webapp_token" {
  program = [
    "bash", "-c",
    <<EOT
      TOKEN=$(az staticwebapp secrets list \
        --name ${azurerm_static_web_app.staticwebapp.name} \
        --resource-group ${var.rg_name} \
        --query "properties.apiKey" -o tsv)
      echo "{ \"token\": \"$TOKEN\" }"
    EOT
  ]
}

output "static_webapp_token" {
  value     = data.external.static_webapp_token.result.token
  sensitive = true
}

# This could be useful to automate secrets on Github
#resource "github_actions_secret" "static_webapp_token" {
#  repository      = var.github_repo
#  secret_name     = "AZURE_STATIC_WEBAPP_TOKEN"
#  plaintext_value = data.external.static_webapp_token.result.token
#}
