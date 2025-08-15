module "rg" {
  source = "./rg"
  rg_name = local.resource_group_name_full
  location = var.location
}

module "budget" {
  source = "./budget"
  email = var.email
}

module "storage" {
  source = "./storage"
  rg_name = module.rg.name
  location = var.location
  storage_account_name = local.storage_account_name_full
  public_ip = var.public_ip
}

module "staticwebapp" {
  source = "./staticwebapp"
  rg_name = module.rg.name
  location = var.location
  static_webapp_name = local.static_webapp_name_full
}

module "webapp" {
  source = "./webapp"
  rg_name = module.rg.name
  location = var.location
  webapp_name = local.webapp_name_full
}

module "network" {
  source = "./network"
  rg_name = module.rg.name
  location = var.location
  vnet_name = local.vnet_name_full
  subnet_name = local.subnet_name_full
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

module "containers" {
  source = "./containers"
  rg_name = module.rg.name
  user4 = module.iad.user4_object_id
  location = var.location
  acr_name = local.acr_name_full
  containers_name = local.containers_name_full
  acisubnet = module.network.acisubnet
}

module "vm" {
  count = 0 # may incur costs
  source = "./vm"
  rg_name = module.rg.name
  location = var.location
  adminsubnet = module.network.adminsubnet
  adminnic = module.network.adminnic
  policy_id = module.backup.policy_id
  vault_name = module.backup.vault_name
  ssh_publickey = var.ssh_publickey
  vm_name = local.vm_name_full
}

module "vmss" {
  count = 0 # may incur costs
  source = "./vmss"
  rg_name = module.rg.name
  location = var.location
  adminsubnet = module.network.adminsubnet
  ssh_publickey = var.ssh_publickey
  vmss_name = local.vmss_name_full
}
