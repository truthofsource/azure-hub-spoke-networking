locals {
  common_tags = {
    environment = "hub"
    workload    = "central-monitoring"
    owner       = var.owner
    managed_by  = "terraform"
    data_class  = "internal"
    criticality = "medium"
    cost_center = var.cost_center
  }
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-example-hub-monitoring-eastus2"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_log_analytics_workspace" "central" {
  name                = "law-example-hub-central-eastus2-001"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = local.common_tags
}

resource "azurerm_monitor_workspace" "workforce_prometheus" {
  count = var.enable_managed_prometheus_workspace ? 1 : 0

  name                = "amw-example-hub-workforce-np-eastus2-001"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  tags                = local.common_tags
}
