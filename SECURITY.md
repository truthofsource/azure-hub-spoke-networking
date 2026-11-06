# Security and evidence boundary

No credentials, cloud account IDs, Terraform state, private input files or employee records belong in this repository. Use only fictional targets in local examples. The loopback-only viewer has no authentication and must not be exposed as a protected service.

Passing address, Terraform mock and browser tests is not assurance of live routing, DNS, NSG, endpoint approval or permission checks for the specific record. Public reference defaults differ from commissioned infrastructure; using them against existing state could propose destructive changes.

The project performs no cloud activation or scan-suppression work. Source secret scanning is separate from dependency/infrastructure security clearance. Report public code issues without attaching private resource inventories, data or tokens.
