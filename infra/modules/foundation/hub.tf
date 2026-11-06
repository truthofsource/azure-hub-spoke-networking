locals {
  connectivity_hub_tags = merge(local.common_tags, {
    workload    = "connectivity-hub"
    data_class  = "internal"
    criticality = "high"
  })
}

resource "azurerm_virtual_network" "hub_production" {
  name                = "vnet-example-hub-production-centralus"
  resource_group_name = module.network.resource_group_name
  location            = module.network.location
  address_space       = ["10.30.0.0/16"]

  tags = local.connectivity_hub_tags
}

# Reserved only. No Azure Firewall resource is deployed under the ~$100/month
# initial architecture.
resource "azurerm_subnet" "azure_firewall_reserved" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = module.network.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_production.name
  address_prefixes     = ["10.30.0.0/26"]
}

# Reserved only. DNS Private Resolver is not deployed until a concrete hybrid
# DNS/custom forwarding requirement exists.
resource "azurerm_subnet" "dns_resolver_inbound_reserved" {
  name                 = "subnet-dns-resolver-inbound-production"
  resource_group_name  = module.network.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_production.name
  address_prefixes     = ["10.30.0.64/28"]
}

resource "azurerm_subnet" "dns_resolver_outbound_reserved" {
  name                 = "subnet-dns-resolver-outbound-production"
  resource_group_name  = module.network.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_production.name
  address_prefixes     = ["10.30.0.80/28"]
}

resource "azurerm_subnet" "azure_firewall_management_reserved" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = module.network.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_production.name
  address_prefixes     = ["10.30.0.128/26"]
}

resource "azurerm_subnet" "shared_private_endpoints_reserved" {
  name                 = "subnet-shared-private-endpoints-production"
  resource_group_name  = module.network.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_production.name
  address_prefixes     = ["10.30.1.0/24"]
}

resource "azurerm_subnet" "gateway_reserved" {
  name                 = "GatewaySubnet"
  resource_group_name  = module.network.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_production.name
  address_prefixes     = ["10.30.2.0/27"]
}

resource "azurerm_subnet" "future_application_integration_reserved" {
  name                 = "subnet-future-application-integration-production"
  resource_group_name  = module.network.resource_group_name
  virtual_network_name = module.network.virtual_network_name
  address_prefixes     = ["10.40.3.0/24"]
}

resource "azurerm_virtual_network_peering" "hub_to_workforce_production" {
  name                      = "peering-hub-to-workforce-production"
  resource_group_name       = module.network.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub_production.name
  remote_virtual_network_id = module.network.virtual_network_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "workforce_to_hub_production" {
  name                      = "peering-workforce-to-hub-production"
  resource_group_name       = module.network.resource_group_name
  virtual_network_name      = module.network.virtual_network_name
  remote_virtual_network_id = azurerm_virtual_network.hub_production.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
