terraform {
  required_version = ">= 1.11.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" } }
}
provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}
module "foundation" {
  count    = var.enable_network ? 1 : 0
  source   = "./modules/foundation"
  location = var.location
  tags     = var.tags
}
output "reference" { value = try(module.foundation[0].peering_policy, null) }
