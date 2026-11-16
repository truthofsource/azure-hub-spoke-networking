# Actual topology versus a reference diagram

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

**Diagram and code boundary:** the PNG, SVG and editable draw.io now show the
accepted November 16 placement. The central VNet is inside the Hub subscription
boundary. The two separated blue boxes have the same production subscription
owner; they are not two subscriptions. The wheel positions, purpose icons and
actual peering relationship are preserved. Gray dotted rays are visual guides,
not routes or new peerings.

The public Terraform excerpts and offline model remain the pre-move teaching
reference. Their address plan and peering intent still apply, but their
single-root ownership is not today's live state layout. The live connectivity
root/state owns both peer children across subscriptions; it is separate from
production's application-spoke owner and Hub monitoring. Backend storage location
does not determine resource subscription ownership. Do not apply this public lab
to adopt or modify the existing deployment. No cloud operation is performed by
publishing the diagram. See [source mapping](SOURCE-MAP.md).

See [Azure networking move limitations](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-limitations/networking-move-limitations),
[changed IDs, dependencies and role-assignment requirements](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription),
and [subscription placement guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-subscriptions).
