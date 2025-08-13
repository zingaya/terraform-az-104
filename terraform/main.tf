module "rg" {
  source = "./rg"
  rg_name = local.resource_group_name_full
  location = var.location
}

module "storage" {
  source = "./storage"
  rg_name = module.rg.name
  location = var.location
  storage_account_name = local.storage_account_name_full
  public_ip = var.public_ip
}

module "webapp" {
  source = "./webapp"
  rg_name = module.rg.name
  location = var.location
  static_webapp_name = local.static_webapp_name_full
  webapp_name = local.webapp_name_full
}

module "network" {
  source = "./network"
  rg_name = module.rg.name
  location = var.location
  vnet_name = local.vnet_name_full
  subnet_name = local.subnet_name_full
}

module "budget" {
  source = "./budget"
  email = var.email
}

module "backup" {
  source = "./backup"
  rg_name = module.rg.name
  location = var.location
  backup_name = local.backup_name_full
}

module "iad" {
  source = "./iad"
}
