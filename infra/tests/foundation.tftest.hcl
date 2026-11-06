mock_provider "azurerm" {}
variables { subscription_id = "00000000-0000-4000-8000-000000000001" }
run "default_off" {
  command = plan
  assert {
    condition     = length(module.foundation) == 0
    error_message = "No infrastructure should be selected by default."
  }
}
run "actual_address_plan" {
  command = plan
  variables { enable_network = true }
  assert {
    condition     = contains(module.foundation[0].address_plan.hub, "10.30.0.0/16") && contains(module.foundation[0].address_plan.spoke, "10.40.0.0/16")
    error_message = "Preserve selected hub and production-spoke ranges."
  }
  assert {
    condition     = contains(module.foundation[0].reserved_capacity.firewall, "10.30.0.0/26") && contains(module.foundation[0].reserved_capacity.gateway, "10.30.2.0/27")
    error_message = "Retain reserved capacity without creating paid appliances."
  }
}
run "reciprocal_peering_without_transit" {
  command = plan
  variables { enable_network = true }
  assert {
    condition     = alltrue([for policy in values(module.foundation[0].peering_policy) : policy.access && !policy.forwarded && !policy.gateway_transit && !policy.remote_gateway])
    error_message = "Both directions must preserve direct access with transit controls Off."
  }
}
