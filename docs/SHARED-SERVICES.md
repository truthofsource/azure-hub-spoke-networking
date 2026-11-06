# Hub, services VNet or separate subscription?

**Terms used here:** A private endpoint gives a supported service an address on a private network; access permissions still apply. DNS turns a service name into the network address used to reach it.

Treat three questions separately: who owns a resource, which network it uses, and who may access it. An Azure subscription/resource group is an ownership and policy scope. A VNet/subnet is a network boundary. A service endpoint or private endpoint changes an access path; it does not grant application or data permissions.

## Connectivity hub

Place shared transit/network services under connectivity ownership: gateway, inspected egress, resolver or management access when justified. Dedicated subnets preserve service requirements. The selected implementation reserves capacity but leaves Firewall, gateway and Private DNS Resolver services deferred. There is no claim of inspected egress or central spoke transit today.

## Shared-service boundary

A developer portal, build tooling or other shared application can use a separate services VNet/resource group and, as scale warrants, its own subscription. That avoids making application lifecycle and restore work part of the transit hub's range of systems a failure could affect. Backstage's separate engineering VNet is the actual example here. Do not infer a production connection simply because both resources have “hub” in their names.

## Managed Azure services

Operational and security workspaces are managed services owned under separate hub resource groups. They are not virtual machines injected into the network. Their readers, retention and selected diagnostic routes have distinct purposes. The monitoring reference includes an existing narrow security-ingestion definition; it is not authorization to add Sentinel ingestion or route all new host logs there.

The shared registry similarly has platform ownership and scoped build/pull identities. Its selected architecture uses an authenticated public service endpoint, not a private endpoint inside a hub subnet. Public endpoint availability is different from anonymous access.

## Workload data stays workload-owned

SQL, sensitive employee documents and their application identity permissions remain workload responsibilities even when network connectivity is shared. Avoid pooling production/nonproduction secrets or broadening contributor roles just to solve a network failure.

| Trigger | Potential change | Tradeoff to evaluate |
| --- | --- | --- |
| Multiple teams with independent releases | Separate services subscription/state ownership | More cross-scope grants, budgets and deployment coordination |
| Hybrid DNS requirement | Commission reviewed resolver/forwarding path | Paid service, DNS availability and cross-network testing |
| Inspected egress requirement | Reviewed firewall/NVA and route design | Cost, latency, symmetric routing and recovery impact |
| New shared application | Dedicated application boundary outside transit services | Additional network placement and permission work |

These are decision criteria, not new deployed features. Different organizations can combine or separate scopes while preserving clear ownership and least privilege.
