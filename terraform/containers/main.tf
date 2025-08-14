######################################
# AZURE CONTAINER REGISTRY
######################################
# Creates a basic ACR (Azure Container Registry) without admin user.
# Only needed if you want to store private images.
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false  # Admin disabled; using roles and managed identities instead
}

# Assigns the "AcrPush" role to a specific user to allow pushing images
resource "azurerm_role_assignment" "acr_push_user4" {
  principal_id         = var.user4
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.acr.id
}

# How to import a public image into your ACR
# Optional, may incur costs
# az acr import --name {your acr_name} --source mcr.microsoft.com/azuredocs/aci-helloworld:latest --image aci-helloworld:latest

######################################
# AZURE CONTAINER INSTANCES
######################################
# Generates a random suffix (hex) to avoid naming collisions
resource "random_id" "suffix" {
  byte_length = 4
}

# Local variable to enable or disable the container group creation
# Optional, may incur costs
# Creates a container in ACI using a public Microsoft image
resource "azurerm_container_group" "hello" {
  count               = 0
  name                = var.containers_name
  location            = var.location
  resource_group_name = var.rg_name
  os_type             = "Linux"

  # System-assigned identity allows role usage (e.g., AcrPull) if needed
  identity {
    type = "SystemAssigned"
  }

  container {
    name   = "helloworld"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"  # Public image; no credentials needed
    cpu    = "0.5"
    memory = "1.0"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  # Networking configuration
  ip_address_type = "Private"         # No public IP, private only
  subnet_ids      = [var.acisubnet]   # Must be a subnet delegated to Microsoft.ContainerInstance
}
