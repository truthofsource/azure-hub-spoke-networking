# Executable network foundation

The root calls a selected foundation module only when enable_network=true. That module includes actual production hub/spoke definitions and the reusable network module, relocated and renamed for the public reference. It retains the production address plan and all reciprocal peering flags. A new read-only module output exposes the actual spoke address space for tests.

```bash
terraform init -backend=false -input=false
terraform fmt -check -recursive
terraform validate
terraform test
```

The three mock cases select no resources by default, verify the actual ranges/reservations, and verify both peerings allow direct VNet access while forwarded traffic, gateway transit and remote-gateway use stay Off. Provider schema is real; resource operations are mocked. No Azure credentials/API calls/apply or remote-state access are needed.

This root does not create any Firewall, resolver, gateway, route-table transit path, database, private endpoint, registry or workspace. References under the top-level reference/ directory are explanatory excerpts and are not loaded by this Terraform root.

Default-Off selection and example labels are public safety/layout adaptations, not values to copy into the live adopted root. There are no import/moved blocks for the real environment. Do not apply this root against existing state or enable it merely to run the local checks.
