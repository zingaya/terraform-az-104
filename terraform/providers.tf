terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=4.38.1"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "=3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "time" { }
