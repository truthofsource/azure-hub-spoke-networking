# Scaling, strengths and tradeoffs

**Terms used here:** A private endpoint gives a supported service an address on a private network; access permissions still apply. DNS turns a service name into the network address used to reach it.

| Choice | Strength | Weakness / tradeoff |
| --- | --- | --- |
| Hub/application-spoke pair | Shared connectivity ownership and separate workload addressing | Peering configuration, traffic cost and route coordination |
| Dedicated integration/endpoint subnets | Clear service placement and independent growth | Address consumption and service-specific sizing constraints |
| Reserved paid-service subnets | Leaves room for later network controls | Reservation alone provides no inspection, gateway or DNS forwarding |
| Separate services VNet/root | Engineering application lifecycle stays outside transit changes | Any cross-network dependency needs explicit connectivity and grants |
| Separate operational/security workspaces | Different readers, retention and selected ingestion | More policy and cost management; not every log belongs in both |
| Authenticated public managed-service endpoint | Can support ordinary hosted CI and scoped identity | Does not provide a private endpoint path; network posture must remain explicit |

Measure traffic by path/region, connection failures, DNS latency, actual IP consumption, managed-service subnet growth, CI/recovery caller needs and team ownership. The public model does not measure any of these.

For more spokes, maintain a centrally reviewed address register and apply consistent naming/tags/state ownership. Adding reciprocal hub peering does not make arbitrary spoke-to-spoke traffic work. If transit is required, design and validate the real forwarding/route/security path. Consider regional hubs when geography, failure isolation or latency warrants them, rather than stretching every dependency through one region.

Introduce Firewall, resolver, gateway, Virtual WAN or centralized policy tooling only when a concrete requirement justifies operating complexity and costs. Review current Azure limits/service requirements before implementation. These are potential evolutions, not deployed features of this reference.

Budget for peering data processing, inter-region transfer, appliance hours, endpoints, DNS queries, monitoring ingestion and recovery tooling. No numerical price estimate is asserted here. A named reserved subnet is not a running appliance charge; a budget alert does not stop spend.

Scale access ownership as well as address space: keep network administration separate from workload data rights, pin state ownership, limit CI identities and test restore/deployment callers after changes. Rehearse partial-failure recovery for DNS, routes and service policy before removing the previous path.
