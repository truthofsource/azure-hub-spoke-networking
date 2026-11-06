# Change, troubleshooting and rollback

**Terms used here:** DNS turns a service name into the network address used to reach it.

## Before a real change

1. Identify the exact root/state owner of the VNet, peering, DNS zone and target service. Shared resource ownership does not mean every definition belongs in one state.
2. Inventory runtime, CI, operator, monitoring and recovery callers and their actual routes/DNS behavior.
3. Check identity/service policy separately from network reachability. Capture the existing selected configuration without storing tokens or business data.
4. Review the exact plan, replacement risk, paid components and dependency order. Preserve a route and DNS rollback path.
5. After an authorized change, verify both directions, effective routes, name resolution and real authorized/denied application behavior from the intended callers.
6. Confirm the owning state has no unintended drift and close temporary exceptions. A zero-change plan is configuration evidence, not a packet or authorization test.

## Troubleshooting

| Symptom | Investigate | Do not assume |
| --- | --- | --- |
| One peering appears Initiated | Both peering resources and remote network IDs/permissions | One direction proves a connected pair |
| Hub can reach both spokes but they cannot reach each other | Transitivity, effective routes, any real forwarding appliance and return path | Hub peering creates automatic transit |
| Public service IP from a private caller | Actual resolver, zone link, record and forwarding | Peering copies DNS settings |
| Correct private IP but timeout | Endpoint approval, route, NSG and service/network policy | DNS success proves an allowed connection |
| Connection succeeds but API/data access denied | Token audience/identity, application roles and record/data grants | Network reachability grants access |
| CI cannot publish after public closure | Hosted runner path, DNS and deployment target | The runner sits inside the hub |
| New service references an existing zone | Exact root/state ownership and shared-record lifecycle | Creating a duplicate zone is a safe shortcut |
| Unexpected cost | Actual appliance/endpoint/gateway activation and traffic | A reserved subnet has appliance billing |

## Rollback boundary

Prepare recovery before changing CIDRs, DNS links, peering or public access. Restore the selected prior route/DNS/service policy only within its owning scope and verify callers again. A Terraform source revert is not a completed rollback until the reviewed plan has been applied and functional evidence recorded. Do not blindly apply an older state or overwrite a shared DNS zone.

The public default-Off wrapper must never be substituted into an existing commissioned state. It changes layout/names for a local reference and does not carry imports/moved blocks for the real environment. No operational rollback or network change was executed for this project.
