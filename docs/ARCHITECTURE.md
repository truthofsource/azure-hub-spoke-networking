# Current topology and retained teaching reference

## Current seven-spoke wheel - accepted November 16, 17:24 UTC

The primary PNG, SVG and editable draw.io show the Hub-owned connectivity VNet
at the center with seven direct peering pairs. Each card labels its subscription
and region. Purple means Hub, blue means Production and gold means Nonproduction;
the color is an ownership label, not a routing or access guarantee.

| Spoke | Subscription / region | Prefix | Accepted state |
| --- | --- | --- | --- |
| Application | Production / Central US | `10.40.0.0/16` | Existing network retained |
| Engineering | Hub / East US 2 | `10.50.0.0/20` | Existing VNet; two new empty reservations |
| Development/test | Nonproduction / East US 2 | `10.20.0.0/16` | Existing VNet; API paused |
| Automation | Hub / Central US | `10.60.0.0/16` | New empty foundation |
| Integration | Hub / Central US | `10.70.0.0/16` | New empty foundation |
| Analytics | Production / Central US | `10.80.0.0/16` | New empty foundation |
| Regional recovery | Production / East US 2 | `10.90.0.0/16` | New empty foundation, no failover |

The hub remains `10.30.0.0/16` in Central US. All fourteen peering records were
Connected at acceptance. The expansion added 72 instances, preserving the
original eleven, with zero updates/deletes and a zero-change post-plan.
Fourteen new empty subnets have their intended NSGs and restricted reservation
policies. Original subnet properties, runtime states and endpoints were preserved.

There is no spoke mesh, automatic hub transit, new staging environment or worker
migration. The four new networks do not supply active applications, VPN/AD,
firewall inspection or tested DR. Managed workspaces/registries are omitted
from the network wheel because they are not VNets inside the hub.

## Retained source example - smaller pre-expansion scope

**Terms used here:** A private endpoint gives a supported service an address on a private network; access permissions still apply.

The retained pre-move production reference defines a connectivity hub (10.30.0.0/16) and application spoke (10.40.0.0/16) in Central US, with a separate peering resource in each direction. Both allow VNet access and disable forwarded traffic, gateway transit and remote gateways. The source defines no Firewall/NVA or user-defined transit route in this selected foundation.

The reusable network module creates the spoke resource group, VNet, integration subnet delegated to Microsoft.App/environments for the selected Functions Flex pattern, and a separate endpoint subnet. Production selects Key Vault and Storage.Global service endpoint entries on integration. Service endpoint entries are not private endpoint NICs and do not close service public access by themselves.

The shared engineering VNet (10.50.0.0/20, East US 2) comes from a different root and supports the selected Backstage VM profile. Its managed Container Apps/PostgreSQL/endpoint subnet declarations originated as alternative reservations. The public reference shows those declarations without treating the alternative services as running. The selected source does not peer this VNet with production.

Nonproduction's application VNet (10.20.0.0/16) is also shown as a separate environment. Other worker/platform networks exist outside this curated scope; this is not a complete Azure resource inventory.

| Statement | Supported by this project? |
| --- | --- |
| Production peering configured in both directions is defined | Yes, actual selected Terraform |
| Every spoke has automatic transit through the hub | No |
| Shared engineering services are in the production hub | No; separate network/root |
| Workspaces and registry are VMs in a hub subnet | No |
| Reserved Firewall/Resolver/Gateway capacity exists | Yes |
| Those paid network services were activated | No |
| Every caller currently resolves/reaches a service correctly | Requires live caller-specific evidence, not tested here |

Azure's hub-spoke architecture separates shared connectivity from workload networks; service placement and ownership remain explicit decisions. [Microsoft architecture reference](https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/hub-spoke).

This portfolio performs no fresh cloud inventory. Dated maintained architecture and mapped source describe implementation context; the local checks validate only the public reference.

## Connectivity hub subscription placement - completed November 16, 2026

The existing Central US connectivity hub VNet (`10.30.0.0/16`) now belongs to
the **Hub subscription**, in a dedicated connectivity resource group. The
application spoke (`10.40.0.0/16`) remains in the **production subscription**.
Only the hub VNet moved; the original resource group also owns the application
spoke and was not moved. The separate East US 2 engineering VNet is unchanged.

All six empty reserved subnets were preserved, and both cross-subscription
peerings are Connected with their original access/transit flags. Azure required
temporarily removing and exactly restoring the two empty firewall-named subnet
reservations. No firewall, gateway, resolver, private endpoint or test VM was
commissioned by the migration.

A dedicated connectivity Terraform root/state now owns the VNet, six subnet
instances, both peering children, destination group and one narrowly scoped
deployment-network role. Nine old state entries were removed without destroying
resources. Both final owner plans proposed zero Azure changes; independent
readback verified the new IDs, subnet policies, peerings, unchanged engineering
network, released state locks and production API HTTP 200. This does not claim
a routed-packet test from the empty hub.

**Current diagram versus retained code:** the three primary formats now show
the later seven-spoke expansion. The preceding move is historical context.
The public Terraform excerpts and offline model remain a smaller pre-move
teaching reference. Their test results do not validate the current wheel's
seven connections. The live connectivity state owns the new foundations and
all peer children; existing engineering/nonproduction VNets and old subnets keep
their original owners. Backend location does not determine resource ownership.
See [source mapping](SOURCE-MAP.md). Publishing this diagram performs no cloud
operation and does not authorize applying the public lab to an existing platform.

See [Azure networking move limitations](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-limitations/networking-move-limitations),
[changed IDs, dependencies and role-assignment requirements](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription),
and [subscription placement guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-subscriptions).
