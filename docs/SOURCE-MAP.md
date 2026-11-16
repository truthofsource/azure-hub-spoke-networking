# Actual source and public adaptations

**Terms used here:** DNS turns a service name into the network address used to reach it.

[Machine mapping](source-map.json) records the original selected file hashes and public locations. Company names and resource labels use neutral examples; no real subscription IDs, endpoint IPs, state, credentials or employee records are included. RFC1918 CIDRs describe the selected architecture but are not reachable targets.

| Source area | Public use | Adaptation |
| --- | --- | --- |
| Reusable network module | Executable Terraform module | Names retained internally where historical addresses matter; added read-only address-space output for inspection |
| Pre-move production network + hub | Executable single-root lab foundation | Neutral labels; address plan/peering preserved, current cross-subscription state ownership is documented separately |
| Owning production root context | New standalone wrapper | Public variables/tags/provider; outer activation defaults Off; no remote backend or live input file |
| Nonproduction module call | Reference only | Neutral labels; owning-root context omitted |
| Engineering-services network | Reference only | Neutral labels; no claimed production peering |
| Monitoring and security definitions | Reference only | Different workspace/ingestion purposes preserved; no new sink activation |
| SQL/documents networking | Reference only | Existing DNS/endpoint pattern shown; owning database/storage/modules not redeployed |
| Offline model and viewer | New example based on the source code | Explicit snapshot, address/relationship checks and local screenshots |

The offline checks are deliberately narrow. They validate address consistency and selected source settings; they are not a Terraform parser, Azure route calculator or firewall/authentication simulator. Missing peerings mean “not defined in this selected source,” not proof that no alternative live route can exist anywhere.

The shared-service resource definitions contain partial historical context. They establish declaration patterns, not a fresh live drift or permission readback. Infrastructure adoption and live source reconciliation require the actual owning state; this standalone example supplies no migration plan for those resources.

## Current diagram - November 16, 2026

The three architecture formats describe the accepted post-move placement: the
connectivity VNet is Hub-owned, the application spoke stays production-owned,
and the separate engineering VNet is unchanged. They replace the prior primary
diagram in place. The original machine source map still identifies the retained
Terraform excerpts; it is not a new source/state snapshot for the completed move.
No private subscription IDs, state, credentials or employee data were added.
