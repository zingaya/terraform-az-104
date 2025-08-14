######################################
# GET DEFAULT DOMAIN
######################################
data "azuread_domains" "default" {
  only_default = true
}

######################################
# LOCAL DEFINITIONS
######################################
locals {
  users = {
    user1 = {
      group      = "CustomerCare"
      admin_unit = "North"
    }
    user2 = {
      group      = "CustomerCare"
      admin_unit = "South"
    }
    user3 = {
      group      = "Sales"
      admin_unit = "North"
    }
    user4 = {
      group      = "Devops"
      admin_unit = "IT"
    }
  }

  groups = ["CustomerCare", "Sales", "Devops"]
  administrative_units = ["North", "South", "IT"]
}

######################################
# CREATE RANDOM PASSWORDS
######################################
resource "random_password" "user_passwords" {
  for_each = local.users

  length           = 16
  special          = true
  numeric          = true
  upper            = true
  override_special = "_%@"

  lifecycle {
    ignore_changes = [
      length,
      lower,
      upper,
      numeric,
      special,
      override_special
    ]
  }
}

######################################
# CREATE USERS
######################################
resource "azuread_user" "users" {
  for_each = local.users

  user_principal_name   = "${each.key}@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = each.key
  password              = random_password.user_passwords[each.key].result
  force_password_change = true
  account_enabled       = true

  lifecycle {
    ignore_changes = [ 
      force_password_change,
      account_enabled,
      password
    ]
  }
}

######################################
# CREATE GROUPS
######################################
resource "azuread_group" "groups" {
  for_each = toset(local.groups)

  display_name     = each.key
  security_enabled = true
  mail_enabled     = false
  mail_nickname    = each.key
}

######################################
# CREATE ADMINISTRATIVE UNITS
######################################
resource "azuread_administrative_unit" "aus" {
  for_each = toset(local.administrative_units)

  display_name = each.key
}

######################################
# ASSIGN USERS TO GROUPS
######################################
resource "azuread_group_member" "group_members" {
  for_each = { for user, info in local.users : user => info if contains(local.groups, info.group) }

  group_object_id  = azuread_group.groups[each.value.group].object_id
  member_object_id = azuread_user.users[each.key].object_id
}

######################################
# ASSIGN USERS TO ADMINISTRATIVE UNITS
######################################
resource "azuread_administrative_unit_member" "admin_unit_members" {
  for_each = { for user, info in local.users : user => info if contains(local.administrative_units, info.admin_unit) }

  administrative_unit_object_id = azuread_administrative_unit.aus[each.value.admin_unit].object_id
  member_object_id              = azuread_user.users[each.key].object_id
}
