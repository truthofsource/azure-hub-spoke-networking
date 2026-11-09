# Routing, DNS and authorization are independent

**Terms used here:** A managed identity lets an Azure service request access without storing a password in the application. A private endpoint gives a supported service an address on a private network; access permissions still apply.

## Direct peering and transit

The source defines a connection in each direction between the production hub and application network. Both allow direct network access, but forwarding and gateway-sharing options stay Off. Connecting two networks to the same hub does not automatically connect them to each other. Actual traffic still depends on routing, network rules and service endpoints. [Microsoft VNet peering overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview).

Setting a peering flag alone would not build a functional firewall or gateway path. A future transit design needs the appliance/gateway, permitted forwarding, route tables, return path and any required DNS/identity checks. This project does not simulate those systems.

## Private DNS needs client links or forwarding

The selected SQL module defines privatelink.database.windows.net, an explicit VNet link and a zone group on the private endpoint. The production root passes the application VNet to that module. The document endpoint references the existing Blob private DNS zone in the connectivity resource group. Reusing an owned zone avoids silently inventing a second owner.

Peering does not automatically give every client the private zone's answers. Link the intended client VNets or design an explicit forwarding path and test from those callers. [Microsoft private endpoint DNS scenarios](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration).

The offline model stores only the selected SQL-link declaration. It performs no DNS query and cannot prove current A records, approved endpoint state or connection success. The actual platform also has existing service-specific private paths and separately deferred additional endpoints; neither “everything is public” nor “everything is private” is accurate.

## Caller checks

| Caller | Network/DNS question | Separate identity/policy question |
| --- | --- | --- |
| Integrated application | Does its actual subnet resolve and route to the intended private service? | Is its managed identity authorized to the exact data? |
| Worker | Does the worker environment use the expected network and DNS? | Are its runtime scopes limited to the right workload? |
| Hosted CI | Can this runner resolve/reach the target? It is not automatically in a spoke. | Can its federated identity deploy only the reviewed scope? |
| Operator | Is access through the reviewed management path or a bounded exception? | Does the signed-in identity have the required read/action rights? |
| Recovery environment | Does the isolated recovery caller reach only the intended recovery services? | Can they restore without gaining broad permanent access? |

Additional storage/vault endpoints remain plans by owner choice. Creating a private endpoint can affect public DNS behavior before every caller is ready, so an “unlinked” preparation alone does not prove zero impact. Do not close public access based solely on a diagram or a successful test from one VM.

## Configure the DNS pieces

The companion [Private DNS walkthrough](https://github.com/truthofsource/azure-private-networking/blob/main/docs/DNS-WALKTHROUGH.md) shows the service zone, caller VNet link and private endpoint zone group separately. It includes the selected Terraform pattern, read-only Azure CLI and DNS queries, portal inspection, expected results and failure diagnosis without creating another project or deploying a resolver.

The November 9 configuration observation found application-VNet-linked zones rather than centralized DNS in the hub subscription. Production retained SQL/Blob records; the nonproduction zones/links remained but had no A records after the November 6 endpoint cost pause. Restoring the affected private paths is a prerequisite to resuming those workloads, not an automatic consequence of restarting compute.

Public applicant/staff CNAME records remain with the external authoritative DNS provider. Azure-provided VNet resolution and Azure Private DNS handle the selected private service names; reserved resolver subnets are not an active Azure DNS Private Resolver. This is a dated configuration read, not a private caller/packet or application-access test.

The walkthrough also compares zone records with the endpoint’s actual NIC addresses when optional DNS metadata is empty. The effective resolver must be checked at the caller; VNet defaults alone do not exclude process-level overrides.
