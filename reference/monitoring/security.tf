locals {
  security_tags = {
    environment = "hub"
    workload    = "security-monitoring"
    owner       = var.owner
    managed_by  = "terraform"
    data_class  = "security"
    criticality = "high"
    cost_center = var.cost_center
  }
}

# Keep security ingestion and incident access independent of operational telemetry.
resource "azurerm_resource_group" "security" {
  name     = "rg-example-hub-security-eastus2"
  location = var.location
  tags     = local.security_tags
}

resource "azurerm_log_analytics_workspace" "security" {
  name                = "law-example-hub-security-eastus2-001"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.security_tags
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "security" {
  workspace_id                 = azurerm_log_analytics_workspace.security.id
  customer_managed_key_enabled = false
}

# Limit initial SIEM ingestion to control-plane, security and policy events.
# Operational traces, records and payloads remain in their existing workspaces.
resource "azurerm_monitor_diagnostic_setting" "hub_activity" {
  name                       = "diag-example-hub-security-activity"
  target_resource_id         = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id

  dynamic "enabled_log" {
    for_each = toset(["Administrative", "Security", "Policy"])
    content {
      category = enabled_log.value
    }
  }

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.security]
}

resource "azurerm_monitor_diagnostic_setting" "nonproduction_activity" {
  provider = azurerm.nonproduction

  name                       = "diag-example-nonproduction-security-activity"
  target_resource_id         = "/subscriptions/${var.nonproduction_subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id

  dynamic "enabled_log" {
    for_each = toset(["Administrative", "Security", "Policy"])
    content {
      category = enabled_log.value
    }
  }

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.security]
}
