# Actual source and public adaptations

[Machine mapping](source-map.json) records the original selected file hashes and public locations. Company names and resource labels use neutral examples; no real subscription IDs, endpoint IPs, state, credentials or employee records are included. RFC1918 CIDRs describe the selected architecture but are not reachable targets.

| Source area | Public use | Adaptation |
| --- | --- | --- |
| Reusable network module | Executable Terraform module | Names retained internally where historical addresses matter; added read-only address-space output for inspection |
| Production network + hub | Executable selected foundation | Neutral resource labels; network module relative path moved |
| Owning production root context | New standalone wrapper | Public variables/tags/provider; outer activation defaults Off; no remote backend or live input file |
| Nonproduction module call | Reference only | Neutral labels; owning-root context omitted |
| Engineering-services network | Reference only | Neutral labels; no claimed production peering |
| Monitoring and security definitions | Reference only | Different workspace/ingestion purposes preserved; no new sink activation |
| SQL/documents networking | Reference only | Existing DNS/endpoint pattern shown; owning database/storage/modules not redeployed |
| Offline model and viewer | New source-derived reference | Explicit snapshot, address/relationship checks and local screenshots |

The offline checks are deliberately narrow. They validate address consistency and selected source settings; they are not a Terraform parser, Azure route calculator or firewall/authentication simulator. Missing peerings mean “not defined in this selected source,” not proof that no alternative live route can exist anywhere.

The shared-service resource definitions contain partial historical context. They establish declaration patterns, not a fresh live drift or permission readback. Infrastructure adoption and live source reconciliation require the actual owning state; this standalone example supplies no migration plan for those resources.
