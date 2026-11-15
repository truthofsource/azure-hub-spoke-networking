# Actual topology versus a reference diagram

**Terms used here:** A private endpoint gives a supported service an address on a private network; access permissions still apply.

The production root defines a connectivity hub (10.30.0.0/16) and application spoke (10.40.0.0/16) in Central US, with a separate peering resource in each direction. Both allow VNet access and disable forwarded traffic, gateway transit and remote gateways. The source defines no Firewall/NVA or user-defined transit route in this selected foundation.

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

## Deferred consideration: connectivity hub subscription placement

The selected source places the production connectivity hub VNet (`10.30.0.0/16`) and application spoke (`10.40.0.0/16`) in the **production subscription**, in the same connectivity resource group. The separately named **Hub subscription** owns selected engineering, monitoring and security services; its engineering VNet is a different network. “Hub VNet” and “Hub subscription” are not interchangeable.

A possible future organizational improvement is to move **only the connectivity hub VNet and its required dependencies** into the Hub subscription. The application spoke, API, databases, documents and website would remain in production unless separately scoped. **Do not move the entire current connectivity resource group:** it also owns the application spoke.

Before any execution, confirm live attachments and Azure move eligibility; plan the required peering interruption and recreation; update changed resource IDs and applicable permissions; and transfer Terraform ownership to one authoritative root/state without unintended replacement. Validate connectivity, DNS, access and the affected owners' plans afterward. The largely reserved source design is not proof that the live hub has no dependencies.

**Status: deferred, documentation only (November 15, 2026).** No resource move, Terraform/state change, peering change or new shared-network service was performed. The existing diagrams and source continue to represent current documented placement. This is a future assessment topic, not an execution runbook or a commitment to move all shared services.

See [Azure networking move limitations](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-limitations/networking-move-limitations), [changed IDs, dependencies and role-assignment requirements](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription), and [subscription placement guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-subscriptions).

