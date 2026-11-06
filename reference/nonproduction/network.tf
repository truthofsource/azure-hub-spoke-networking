module "network" {
  source                            = "../../modules/network"
  location                          = var.location
  address_space                     = ["10.20.0.0/16"]
  functions_subnet_prefixes         = ["10.20.1.0/24"]
  private_endpoints_subnet_prefixes = ["10.20.2.0/24"]
  tags                              = local.network_tags
  resource_group_name               = "rg-example-network-nonproduction-eastus2"
  virtual_network_name              = "vnet-example-app-nonproduction-eastus2"
  functions_subnet_name             = "snet-functions-integration-nonproduction"
  private_endpoints_subnet_name     = "snet-private-endpoints-nonproduction"
}
