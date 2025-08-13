######################################
# APPLICATION SECURITY GROUPS (ASGs)
######################################

locals {
  # Collect all unique ASGs from NICs
  used_asgs = distinct(flatten([
    for nic in values(var.nics) : nic.asgs
  ]))
}

resource "azurerm_application_security_group" "asg" {
  for_each            = toset(local.used_asgs)
  name                = "asg-${each.value}"
  resource_group_name = var.rg_name
  location            = var.location
}

######################################
# NETWORK SECURITY GROUP (NSG)
######################################

resource "azurerm_network_security_group" "main" {
  name                = "nsg-main"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to all security_rule blocks except the initial one
      security_rule
    ]
  }
}

######################################
# ASSOCIATE NSG TO SUBNET
######################################

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.main0.id
  network_security_group_id = azurerm_network_security_group.main.id
}

######################################
# ASG ASSOCIATIONS (MULTIPLE PER NIC)
######################################

locals {
  nic_asg_pairs = flatten([
    for nic_name, nic in var.nics : [
      for asg in nic.asgs : {
        nic_name = nic_name
        asg_name = asg
      }
    ]
  ])
}

resource "azurerm_network_interface_application_security_group_association" "asg_assoc" {
  for_each = {
    for pair in local.nic_asg_pairs : "${pair.nic_name}-${pair.asg_name}" => pair
  }

  network_interface_id          = azurerm_network_interface.nic[each.value.nic_name].id
  application_security_group_id = azurerm_application_security_group.asg[each.value.asg_name].id
}

######################################
# ADDITIONAL NSG RULE: ALLOW HTTP FOR ADMIN TO WEB ASG ONLY
######################################

resource "azurerm_network_security_rule" "adminrule1" {
  name                        = "Allow-8080-Admin-Subnet"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "10.0.1.0/24"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.main.name

  destination_application_security_group_ids = [
    azurerm_application_security_group.asg["web_asg"].id
  ]
}

resource "azurerm_network_security_rule" "adminrule2" {
  name                        = "Allow-Mysql-Admin-Subnet"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = "10.0.1.0/24"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.main.name

  destination_application_security_group_ids = [
    azurerm_application_security_group.asg["sql_asg"].id
  ]
}

resource "azurerm_network_security_rule" "rule1" {
  name                       = "Allow-SSH-From-Admin-Subnet"
  priority                   = 1000
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "10.0.1.0/24"
  destination_address_prefix = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "rule2" {
  name                        = "Allow-MySQL-From-Web-ASG"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.main.name

  source_application_security_group_ids      = [azurerm_application_security_group.asg["web_asg"].id]
  destination_application_security_group_ids = [azurerm_application_security_group.asg["sql_asg"].id]
}
