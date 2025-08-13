output "storage_sas_token" {
  value     = module.storage.sas_token
  sensitive = true
}
