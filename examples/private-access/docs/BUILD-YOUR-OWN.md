# Build your own from scratch: Azure Private Networking

A private Blob endpoint and private DNS path in your own VNet, with an explicit DNS/network test.

Start with a new folder, your own files and your own accounts. The numbered steps below describe the build; no portfolio repository checkout is required. The existing implementation/evidence elsewhere in this repository is a separate reference, not a claim that your new build has already passed.

## Prerequisites

Azure subscription; permission for a storage account, VNet, private endpoint and DNS zone; an authorized client inside that VNet or a connected network. Endpoints and any test VM have ongoing charges.

Use Bash on Linux/macOS/WSL for Bash blocks and PowerShell for PowerShell blocks. Select the tool versions supported by the official sources below, record the versions you actually install and retain generated dependency locks. Cloud resources, scanner downloads, logs and external AI calls can create costs; review the stated scope before enabling them.

## Create your project folder

Choose a new folder name. These first commands create a blank project; an optional `git init` gives it its own history. Create parent directories in your editor when a later step introduces a nested file.

```bash
mkdir my-azure-private-networking
cd my-azure-private-networking
git init
```

Create `.gitignore` before saving credentials or build outputs:

```gitignore
.venv/
node_modules/
.env
.env.*
local.settings.json
credentials.json
token.json
*.pem
*.key
*.tfstate*
*.tfplan
.terraform/
private*/
captures/
backups/
batch.json
reports/
out/
app-config.local.yaml
```

The source/file snippets are a starting implementation you type or paste into the named files. Replace `YOUR_*`, names, regions and addresses only with values from your own lab; do not place real client/employee records in a test project. Keep your terminal in this project root unless a step explicitly changes directory.

Before a first commit, set your own repository-local author with `git config user.name "YOUR_NAME"` and `git config user.email "YOUR_PUBLIC_COMMIT_EMAIL"`. Review `git status --short` and the staged diff before publishing; ignored local files are not a substitute for reviewing what you upload.

## Step 1 — Choose your names and client path

**Where:** Your design notes.

Choose a unique lowercase storage account name, one VNet/subnet and an isolated resource group. Identify the client that will resolve and call the storage service; Cloud Shell on a public path is not automatically inside your VNet.

**Check before continuing:** You can draw client → DNS → private endpoint → Blob service.

## Step 2 — Create the storage account and private container

**Where:** Azure Portal → Storage accounts → Create.

Create a StorageV2 account with your selected redundancy and TLS minimum, disable anonymous Blob access and Shared Key, and create a private container named documents. Keep public network access closed once the private caller path is ready. Before using the Portal container interface, establish the intended test identity's scoped Blob data role; management ownership alone is not a data-plane grant.

**Check before continuing:** The account and container exist; anonymous data access is not enabled.

## Step 3 — Create your network and endpoint

**Where:** Azure Portal → Virtual networks; then Storage account → Networking → Private endpoints.

Create your VNet and endpoint subnet if you do not already have an isolated one. Add a private endpoint for the Blob subresource, selecting your account and that subnet; note the endpoint private IP.

**Check before continuing:** The endpoint connection is Approved and the private NIC has an address in your selected subnet.

## Step 4 — Connect private DNS

**Where:** Private endpoint creation / Private DNS zones.

Enable integration with privatelink.blob.core.windows.net and link that zone to the client VNet. Confirm the account A record matches the endpoint NIC rather than creating an unrelated public DNS record.

**Check before continuing:** Your client VNet is linked and the Blob private record matches the NIC.

## Step 5 — Test from the intended client

**Where:** Inside your client VM or connected network.

Resolve the ordinary ACCOUNT.blob.core.windows.net name and verify the resolved private IP. Test HTTPS and then a permitted Blob operation using Entra authentication with a separately assigned data role; a port connection alone is not an authorization test.

```powershell
Resolve-DnsName -Name "YOUR_ACCOUNT.blob.core.windows.net"
Test-NetConnection -ComputerName "YOUR_ACCOUNT.blob.core.windows.net" -Port 443
```

**Check before continuing:** DNS, network reachability and data authorization have three separately recorded outcomes.

## Step 6 — Test denial and finish

**Where:** An off-network test client and Azure Portal.

Check that the unapproved public client cannot read the private container, without opening the account to troubleshoot. Capture your DNS/endpoint/authorization evidence, then delete only your lab endpoint, DNS link, account and any lab compute after reviewing retained data.

**Check before continuing:** The intended private caller works, the unapproved caller is denied, and remaining costs are accounted for.

## Verification and your own screenshots

| Evidence | What to record | Your result |
| --- | --- | --- |
| New build | Your own files/resource settings and tool versions | Not yet recorded |
| Working path | The actual successful request, configuration or recovery result | Not yet recorded |
| Failure boundary | A meaningful denied, malformed, stale or failed case | Not yet recorded |
| Recovery / cleanup | What you restored or removed and what remains billed | Not yet recorded |

Capture your own architecture/configuration, one working result and one failure/recovery result. Keep tokens, credentials, personal records and private identifiers out of public screenshots. The architecture diagram explains the design; record your own results rather than treating it as execution evidence.

## Troubleshooting order

1. Confirm the named file, working directory and selected tool/interpreter.
2. Check the exact input and resource/account selected for the failing step.
3. Separate identity permission, network/DNS reachability and application validation.
4. Keep the actual error and reconcile an unknown write outcome before repeating it; do not widen access or repeat paid operations blindly.

The numbered steps describe a build procedure. Local syntax checks, an accepted API request, a completed hosted operation and a human verification are different evidence levels; fill in the verification table with what you actually observed.

## Official implementation references

- [learn.microsoft.com — storage-private-endpoints](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [learn.microsoft.com — private-endpoint-dns](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
