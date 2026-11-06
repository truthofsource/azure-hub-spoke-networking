# Address planning and reservations

| Network | Range | Selected purpose |
| --- | --- | --- |
| Production connectivity hub | 10.30.0.0/16 | Reciprocal connectivity to production spoke; future shared network controls |
| Production application spoke | 10.40.0.0/16 | Application integration, data endpoints and growth |
| Nonproduction application network | 10.20.0.0/16 | Separate workload environment |
| Shared engineering VNet | 10.50.0.0/20 | Engineering-service network owned separately |

The hub reserves 10.30.0.0/26 for AzureFirewallSubnet, 10.30.0.128/26 for AzureFirewallManagementSubnet, 10.30.0.64/28 and 10.30.0.80/28 for resolver capacity, 10.30.1.0/24 for shared endpoint capacity, and 10.30.2.0/27 for GatewaySubnet. The names/reservations do not provision appliances or forwarding.

Production uses 10.40.1.0/24 for Functions integration, 10.40.2.0/24 for private endpoints and reserves 10.40.3.0/24 for future integration. Nonproduction uses corresponding 10.20.1.0/24 and 10.20.2.0/24 ranges. The shared engineering root reserves 10.50.0.0/23, 10.50.2.0/27 and 10.50.2.32/27 for managed alternatives; the broader VM profile has its own additional subnet outside the selected reservation reference.

`data/topology.json` is an explicit source-derived snapshot. Tests compare each included prefix to mapped Terraform and reject overlapping VNet/subnet ranges, escaped subnets and duplicate peerings. Python's ipaddress library validates strict network boundaries; this is not a live address-management system or Terraform parser.

When adding a network, compare against all on-premises, cloud, VPN and peered ranges—not just these four. Reserve growth around integration/delegated subnets, review service-specific subnet requirements and verify limits/costs at the time of commissioning. CIDR changes to used networks/subnets may replace resources or disrupt callers; review the plan and rollback before changing them.
