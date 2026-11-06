# Routing, DNS and authorization are independent

**Terms used here:** A managed identity lets an Azure service request access without storing a password in the application. A private endpoint gives a supported service an address on a private network; access permissions still apply.

## Direct peering and transit

The source contains two reciprocal production peering resources. Both enable VNet access while leaving forwarded traffic, gateway transit and remote-gateway use false. Peering supplies direct connectivity declarations; it does not automatically create a spoke-to-spoke transit path. Actual flows still depend on routes, NSGs and endpoints. [Microsoft VNet peering overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview).

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
| Recovery environment | Do restore into a separate test environment callers reach only intended recovery services? | Can they restore without gaining broad permanent access? |

Additional storage/vault endpoints remain plans by owner choice. Creating a private endpoint can affect public DNS behavior before every caller is ready, so an “unlinked” preparation alone does not prove zero impact. Do not close public access based solely on a diagram or a successful test from one VM.
