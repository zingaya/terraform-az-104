output "storage_sas_token" {
  value     = module.storage.sas_token
  sensitive = true
}

output "static_webapp_host" {
  value     = module.staticwebapp.static_webapp_host
}

output "static_webapp_token" {
  value     = module.staticwebapp.static_webapp_token
  sensitive = true
}
