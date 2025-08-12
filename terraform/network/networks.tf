######################################
# VIRTUAL NETWORK AND SUBNETS
######################################

# Create a Virtual Network with a /23 address space (512 IPs)
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/23"]
  resource_group_name = var.rg_name
  location            = var.location
}

# Create two subnets within the VNet, each with a /24 block (256 IPs)
resource "azurerm_subnet" "main0" {
  name                 = "${var.subnet_name}-0"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "main1" {
  name                 = "${var.subnet_name}-1"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

######################################
# NETWORK INTERFACES (NICs)
######################################

# Pre-create NICs for web and SQL servers to avoid provisioning full VMs and reduce costs
resource "azurerm_network_interface" "web1" {
  name                = "web1"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "web2" {
  name                = "web2"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "sql1" {
  name                = "sql1"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "sql2" {
  name                = "sql2"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "admin1" {
  # NIC for admin VM placed in separate subnet to isolate admin network traffic
  name                = "admin1"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main1.id
    private_ip_address_allocation = "Dynamic"
  }
}
