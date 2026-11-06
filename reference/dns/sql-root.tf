locals {
  sql_tags = merge(local.common_tags, {
    workload    = "workforce-data"
    data_class  = "confidential"
    criticality = "medium"
  })
}

module "sql" {
  source                          = "../../modules/sql"
  resource_group_location         = var.sql_location
  location                        = var.sql_location
  resource_group_name             = "rg-example-data-production-centralus"
  server_name                     = var.sql_server_name
  database_name                   = var.sql_database_name
  database_sku_name               = "S0"
  database_max_size_gb            = var.sql_database_max_size_gb
  database_storage_account_type   = "Geo"
  short_term_retention_days       = 14
  administrator_object_id         = var.platform_owners_group_object_id
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  tags                            = local.sql_tags
  network_resource_group_name     = module.network.resource_group_name
  network_location                = module.network.location
  virtual_network_id              = module.network.virtual_network_id
  private_endpoints_subnet_id     = module.network.private_endpoints_subnet_id
  dns_link_name                   = "private-dns-link-sql-workforce-production"
  private_endpoint_name           = "private-endpoint-sql-workforce-production-001"
  private_service_connection_name = "private-service-connection-sql-workforce-production-001"
  private_dns_zone_group_name     = "private-dns-zone-group-sql-workforce-production-001"
}
