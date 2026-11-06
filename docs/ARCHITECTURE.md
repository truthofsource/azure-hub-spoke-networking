# Actual topology versus a reference diagram

The production root defines a connectivity hub (10.30.0.0/16) and application spoke (10.40.0.0/16) in Central US, with a separate peering resource in each direction. Both allow VNet access and disable forwarded traffic, gateway transit and remote gateways. The source defines no Firewall/NVA or user-defined transit route in this selected foundation.

The reusable network module creates the spoke resource group, VNet, integration subnet delegated to Microsoft.App/environments for the selected Functions Flex pattern, and a separate endpoint subnet. Production selects Key Vault and Storage.Global service endpoint entries on integration. Service endpoint entries are not private endpoint NICs and do not close service public access by themselves.

The shared engineering VNet (10.50.0.0/20, East US 2) comes from a different root and supports the selected Backstage VM profile. Its managed Container Apps/PostgreSQL/endpoint subnet declarations originated as alternative reservations. The public reference shows those declarations without treating the alternative services as running. The selected source does not peer this VNet with production.

Nonproduction's application VNet (10.20.0.0/16) is also shown as a separate environment. Other worker/platform networks exist outside this curated scope; this is not a complete Azure resource inventory.

| Statement | Supported by this project? |
| --- | --- |
| Production reciprocal peering is defined | Yes, actual selected Terraform |
| Every spoke has automatic transit through the hub | No |
| Shared engineering services are in the production hub | No; separate network/root |
| Workspaces and registry are VMs in a hub subnet | No |
| Reserved Firewall/Resolver/Gateway capacity exists | Yes |
| Those paid network services were activated | No |
| Every caller currently resolves/reaches a service correctly | Requires live caller-specific evidence, not tested here |

Azure's hub-spoke architecture separates shared connectivity from workload networks; service placement and ownership remain explicit decisions. [Microsoft architecture reference](https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/hub-spoke).

This portfolio performs no fresh cloud inventory. Dated maintained architecture and mapped source describe implementation context; the local checks validate only the public reference.
