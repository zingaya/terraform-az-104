resource "azurerm_virtual_network" "main" {
  name = var.vnet_name
  address_space = ["10.0.0.0/23"]
  resource_group_name = var.rg_name
  location = var.location
}

resource "azurerm_subnet" "main0" {
  name = "${var.subnet_name}-0"
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "main1" {
  name = "${var.subnet_name}-1"
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "web1" {
  name = "web1"
  resource_group_name = var.rg_name
  location = var.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "web2" {
  name = "web2"
  resource_group_name = var.rg_name
  location = var.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "sql1" {
  name = "sql1"
  resource_group_name = var.rg_name
  location = var.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "sql2" {
  name = "sql2"
  resource_group_name = var.rg_name
  location = var.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "admin1" {
  name = "admin1"
  resource_group_name = var.rg_name
  location = var.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_application_security_group" "web_asg" {
  name = "asg-web"
  resource_group_name = var.rg_name
  location = var.location
}

resource "azurerm_application_security_group" "sql_asg" {
  name = "asg-sql"
  resource_group_name = var.rg_name
  location = var.location
}

resource "azurerm_network_security_group" "main" {
  name = "nsg-main"
  location = var.location
  resource_group_name = var.rg_name

  security_rule {
    name = "Allow-SSH"
    priority = 130
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "empty" {
  name = "nsg-empty"
  location = var.location
  resource_group_name = var.rg_name
}

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

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.main0.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_security_rule" "rule2" {
  name                        = "Allow-HTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.main.name

  destination_application_security_group_ids = [
    azurerm_application_security_group.web_asg.id
  ]
}
