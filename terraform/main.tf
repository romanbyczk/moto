terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "moto-tfstate-rg"
    storage_account_name = "mototfstate"
    container_name       = "tfstate"
    key                  = "moto.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  prefix = "${var.project_name}-${var.environment}"
}

# =============================================================================
# Resource Group
# =============================================================================
resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-rg"
  location = var.location

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# =============================================================================
# Azure Container Registry
# =============================================================================
resource "azurerm_container_registry" "acr" {
  name                = replace("${local.prefix}acr", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = azurerm_resource_group.main.tags
}

# =============================================================================
# AKS Cluster
# =============================================================================
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.prefix}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${local.prefix}-aks"

  default_node_pool {
    name                 = "default"
    vm_size              = var.aks_node_vm_size
    node_count           = var.aks_node_count
    min_count            = var.aks_node_count
    max_count            = var.aks_max_node_count
    auto_scaling_enabled = true
    vnet_subnet_id       = azurerm_subnet.aks.id

    temporary_name_for_rotation = "tmpdefault"
  }

  identity {
    type = "SystemAssigned"
  }

  api_server_access_profile {
    authorized_ip_ranges = var.aks_authorized_ip_ranges
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  tags = azurerm_resource_group.main.tags
}

# =============================================================================
# Log Analytics Workspace
# =============================================================================
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.prefix}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = azurerm_resource_group.main.tags
}

# =============================================================================
# Grant AKS pull access to ACR
# =============================================================================
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
