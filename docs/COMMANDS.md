# Commands and ClickOps

## Offline checks — performed for this portfolio

```bash
python -B -m unittest discover -s tests -v
python -B -m lab.topology
python -B scripts/preview.py
```

Use Python 3.12. The tests need only the standard library. Open http://127.0.0.1:8137 for the loopback-only viewer; Ctrl+C stops it. The six demonstration rows report declaration relationships, not packet delivery.

```bash
terraform -chdir=infra init -backend=false -input=false
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
terraform -chdir=infra test
```

Terraform 1.11 or later initializes signed provider packages; the lockfile records the selected version. The three test cases use mocked AzureRM and a fictional subscription. No cloud account, backend, apply or resource lookup is required.

## Read-only Azure inspection examples — not run for this portfolio

Choose the reviewed subscription and resource names privately; these commands query actual resources and require your own authorized session.

```bash
az network vnet peering list --resource-group "$NETWORK_RG" --vnet-name "$HUB_VNET" --output table
az network vnet peering list --resource-group "$NETWORK_RG" --vnet-name "$SPOKE_VNET" --output table
az network vnet subnet list --resource-group "$NETWORK_RG" --vnet-name "$SPOKE_VNET" --output table
az network private-dns link vnet list --resource-group "$DNS_RG" --zone-name privatelink.database.windows.net --output table
az network nic show-effective-route-table --resource-group "$NIC_RG" --name "$NIC_NAME" --output table
```

Effective-route inspection applies to an appropriate NIC/caller. It does not represent every managed-service host. Use a reviewed existing runtime/probe path for Functions or managed workers; do not start a VM or enable services just to obtain a screenshot.

From an intended caller on Linux:

```bash
getent ahostsv4 "$SERVICE_FQDN"
```

On Windows PowerShell:

```powershell
Resolve-DnsName -Name $serviceFqdn
Test-NetConnection -ComputerName $serviceFqdn -Port 443
```

Choose the actual service port rather than assuming every target uses 443. A name/port test is not database login or application authorization. Do not include private names, token-bearing commands or customer records in public screenshots.

## ClickOps reference

- Azure Portal → Virtual networks → selected VNet → Address space/Subnets: confirm source plan and delegation.
- VNet → Peerings: inspect each direction and state. Do not enable transit as an exploratory fix.
- Private DNS zones → selected zone → Virtual network links/Recordsets: check intended clients and record ownership.
- Network interface → Effective routes/Effective security rules: inspect an appropriate active caller.
- Target service → Networking/IAM: distinguish endpoint/network policy from identity permissions.
- Resource group/subscription → Access control/Cost analysis: inspect ownership and costs separately from VNet placement.

These are inspection instructions, not actions performed on Azure during project creation.
