######################################
# APPLICATION SECURITY GROUPS (ASGs)
######################################

# Group NICs representing webservers for easier NSG rules targeting
resource "azurerm_application_security_group" "web_asg" {
  name                = "asg-web"
  resource_group_name = var.rg_name
  location            = var.location
}

# Group NICs representing mysql servers for easier NSG rules targeting
resource "azurerm_application_security_group" "sql_asg" {
  name                = "sql-web"
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

  # Deny all inbound traffic by default - Least Privilege
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

  # Allow SSH inbound only from admin subnet CIDR range (example: 10.0.1.0/24)
  security_rule {
    name                       = "Allow-SSH-From-Admin-Subnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.1.0/24" # Admin subnet CIDR (replace as needed)
    destination_address_prefix = "*"
  }

  # Allow MySQL inbound (port 3306) from webservers ASG to SQL servers ASG
  security_rule {
    name                        = "Allow-MySQL-From-Web-ASG"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "3306"
    source_application_security_group_ids      = [azurerm_application_security_group.web_asg.id]
    destination_application_security_group_ids = [azurerm_application_security_group.sql_asg.id]
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
# ASSOCIATE IP CONFIGURATION TO ASGs
######################################

resource "azurerm_network_interface_application_security_group_association" "web1_asg" {
  network_interface_id          = azurerm_network_interface.web1.id
  application_security_group_id = azurerm_application_security_group.web_asg.id
}

resource "azurerm_network_interface_application_security_group_association" "web2_asg" {
  network_interface_id          = azurerm_network_interface.web2.id
  application_security_group_id = azurerm_application_security_group.web_asg.id
}

resource "azurerm_network_interface_application_security_group_association" "sql1_asg" {
  network_interface_id          = azurerm_network_interface.sql1.id
  application_security_group_id = azurerm_application_security_group.sql_asg.id
}

resource "azurerm_network_interface_application_security_group_association" "sql2_asg" {
  network_interface_id          = azurerm_network_interface.sql2.id
  application_security_group_id = azurerm_application_security_group.sql_asg.id
}

######################################
# ADDITIONAL NSG RULE: ALLOW HTTP FOR ADMIN TO WEB ASG ONLY
######################################

resource "azurerm_network_security_rule" "rule2" {
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

  # Restrict HTTP traffic only to NICs assigned to the web ASG
  destination_application_security_group_ids = [
    azurerm_application_security_group.web_asg.id
  ]
}
