######################################
# VIRTUAL NETWORK AND SUBNETS
######################################

# Create a Virtual Network with a /23 address space (512 IPs)
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/23", "10.0.2.0/24"]
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

# Subnet for ACI
resource "azurerm_subnet" "main2" {
  name                 = "${var.subnet_name}-2"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

# Need to be delegated
  delegation {
    name = "aci-delegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

######################################
# NETWORK INTERFACES (NICs)
######################################

resource "azurerm_network_interface" "nic" {
  for_each            = var.nics
  name                = each.key
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = lookup({
      "0" = azurerm_subnet.main0.id,
      "1" = azurerm_subnet.main1.id
    }, each.value.subnet_suffix)
    private_ip_address_allocation = "Dynamic"
  }
}
