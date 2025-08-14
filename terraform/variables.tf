######################################
# VARIABLES YOU WILL MOST LIKELY EDIT
######################################

# Default Azure location for resources
variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure region where resources will be created."
}

######################################
# NAMING CONTROL — COMMON PREFIX/POSTFIX
######################################

# Unique prefix for all resource names
# Avoid dashes here — script will insert them where needed.
variable "prefix" {
  type        = string
  default     = "mylab"
  description = "Unique prefix for naming resources (no dashes)."
}

# Postfix for all resource names
variable "postfix" {
  type        = string
  default     = "101"
  description = "Unique postfix for naming resources."
}

######################################
# USE secrets.tfvars
######################################

# Azure subscription ID — keep in secrets.tfvars, not in main.tfvars
# Reason: This is account-specific information that can be considered sensitive.
variable "subscription_id" {
  type        = string
  sensitive   = true
  description = "Azure subscription ID (stored in secrets.tfvars)"
}

# Azure tenant ID — keep in secrets.tfvars
# Reason: It uniquely identifies your Azure AD tenant and should not be hardcoded in repo.
variable "tenant_id" {
  type        = string
  sensitive   = true
  description = "Azure tenant ID (stored in secrets.tfvars)"
}

# Public IP(s) to allow — keep in secrets.tfvars
# Reason: Your public IP is private info and could be used for targeted attacks.
# If empty, Terraform will configure the resource to allow public access from anywhere.
variable "public_ip" {
  type        = list(string)
  sensitive   = true
  default     = []
  description = "List of allowed public IPs (empty = allow all). Store in secrets.tfvars."
}

# Budget alert email
variable "email" {
  type        = list(string)
  sensitive   = true
  description = "Email budget alerts (stored in secrets.tfvars)"
}

# SSH Public key file
variable "ssh_publickey" {
  type        = string
  sensitive   = true
  description = "SSH Public key file (stored in secrets.tfvars)"
}

######################################
# OPTIONAL: RESOURCE NAME BASES
######################################

variable "resource_group_name" {
  type        = string
  default     = "rg"
  description = "Base name for resource group."
}

variable "storage_account_name" {
  type        = string
  default     = "storage"
  description = "Base name for storage account (must be globally unique when combined)."
}

variable "static_webapp_name" {
  type        = string
  default     = "staticwebapp"
}

variable "webapp_name" {
  type        = string
  default     = "webapp"
}

variable "function_app_name" {
  type        = string
  default     = "funcapp"
}

variable "vnet_name" {
  type        = string
  default     = "vnet"
}

variable "subnet_name" {
  type        = string
  default     = "subnet"
}

variable "containers_name" {
  type        = string
  default     = "container"
}

variable "acr_name" {
  type        = string
  default     = "acr"
}

variable "backup_name" {
  type        = string
  default     = "backup"
}

variable "iad_name" {
  type        = string
  default     = "iad"
}

variable "app_name" {
  type        = string
  default     = "webapp"
}

######################################
# LOCALS: AUTOMATED NAME GENERATION
######################################

locals {
  # Apply prefix and postfix with dashes automatically if values are set
  local_prefix  = var.prefix  != "" ? "${var.prefix}-" : ""
  local_postfix = var.postfix != "" ? "-${var.postfix}" : ""

  resource_group_name_full   = "${local.local_prefix}${var.resource_group_name}${local.local_postfix}"
  storage_account_name_full  = "${var.prefix}${var.storage_account_name}${var.postfix}" # Storage accounts can't have dashes
  static_webapp_name_full    = "${local.local_prefix}${var.static_webapp_name}${local.local_postfix}"
  webapp_name_full           = "${local.local_prefix}${var.webapp_name}${local.local_postfix}"
  function_app_name_full     = "${local.local_prefix}${var.function_app_name}${local.local_postfix}"
  vnet_name_full             = "${local.local_prefix}${var.vnet_name}${local.local_postfix}"
  subnet_name_full           = "${local.local_prefix}${var.subnet_name}${local.local_postfix}"
  acr_name_full              = "${var.prefix}${var.acr_name}${var.postfix}"
  containers_name_full       = "${local.local_prefix}${var.containers_name}${local.local_postfix}"
  backup_name_full           = "${local.local_prefix}${var.backup_name}${local.local_postfix}"
  iad_name_full              = "${local.local_prefix}${var.iad_name}${local.local_postfix}"
  app_name_full              = "${local.local_prefix}${var.app_name}${local.local_postfix}"
}
