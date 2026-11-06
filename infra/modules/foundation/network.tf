locals {
  network_tags = merge(local.common_tags, {
    workload    = "network"
    data_class  = "internal"
    criticality = "medium"
  })
}

module "network" {
  source                             = "../network"
  location                           = var.location
  address_space                      = ["10.40.0.0/16"]
  functions_subnet_prefixes          = ["10.40.1.0/24"]
  functions_subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage.Global"]
  private_endpoints_subnet_prefixes  = ["10.40.2.0/24"]
  tags                               = local.network_tags
  resource_group_name                = "rg-example-connectivity-production-centralus"
  virtual_network_name               = "vnet-example-workforce-production-centralus"
  functions_subnet_name              = "subnet-functions-integration-production"
  private_endpoints_subnet_name      = "subnet-private-endpoints-production"
}
