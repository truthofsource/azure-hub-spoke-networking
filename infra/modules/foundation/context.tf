terraform {
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" } }
}
variable "location" { type = string }
variable "tags" { type = map(string) }
locals { common_tags = var.tags }
output "address_plan" {
  value = { hub = azurerm_virtual_network.hub_production.address_space, spoke = module.network.address_space }
}
output "peering_policy" {
  value = {
    hub_to_spoke = { access = azurerm_virtual_network_peering.hub_to_workforce_production.allow_virtual_network_access, forwarded = azurerm_virtual_network_peering.hub_to_workforce_production.allow_forwarded_traffic, gateway_transit = azurerm_virtual_network_peering.hub_to_workforce_production.allow_gateway_transit, remote_gateway = azurerm_virtual_network_peering.hub_to_workforce_production.use_remote_gateways }
    spoke_to_hub = { access = azurerm_virtual_network_peering.workforce_to_hub_production.allow_virtual_network_access, forwarded = azurerm_virtual_network_peering.workforce_to_hub_production.allow_forwarded_traffic, gateway_transit = azurerm_virtual_network_peering.workforce_to_hub_production.allow_gateway_transit, remote_gateway = azurerm_virtual_network_peering.workforce_to_hub_production.use_remote_gateways }
  }
}
output "reserved_capacity" {
  value = { firewall = azurerm_subnet.azure_firewall_reserved.address_prefixes, gateway = azurerm_subnet.gateway_reserved.address_prefixes, shared_endpoints = azurerm_subnet.shared_private_endpoints_reserved.address_prefixes }
}
