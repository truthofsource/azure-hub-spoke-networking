> This example is maintained within **azure-hub-spoke-networking**. Run its local commands from this subfolder; its nested workflow files are retained examples and are not active repository workflows. See [the consolidation guide](https://github.com/truthofsource/azure-hub-spoke-networking/blob/main/docs/CONSOLIDATION.md).

# Secure Cloud Networking & Private Access

**Let people reach the application while limiting access to its database and documents.**

[The problem](#the-business-problem) · [The solution](#the-solution) · [What was built](#what-was-built) · [Proof it works](#proof-it-works) · [Run it](#run-it-locally) · [Step by step](#step-by-step)

## The Business Problem

Staff and applicants need reliable access to the website, while employee documents and the database need tighter protection. The same backend services must also be reachable by deployment tools, file processors and recovery procedures. Each of those callers may take a different network path.

Restricting a service without checking those paths can leave a website that opens but cannot save an application, retrieve a document or complete a deployment. Name-lookup changes can produce similar symptoms, making a connection problem look like an application or permission failure. Temporary troubleshooting access also needs a defined closing procedure.

The business need was to limit direct access to sensitive services while preserving the connections required for daily work, releases and recovery, with enough evidence to explain which path failed.

## The Solution

Separate application and private-service network areas. Check the connection path, name lookup and permissions from each type of caller before changing public access. Keep additional private connections optional until those checks are complete.

**Business outcome:** Improve data protection while preserving the access needed by staff, deployment tools, monitoring and recovery.

### Platform implementation

- Organized shared services and workload networks using parameterized Terraform modules rather than duplicating each environment.
- Used a dedicated application-integration subnet and a separate private-endpoint subnet, with resource ownership, naming and tags supplied as inputs.
- Operated a protected SQL path with separately controlled, time-limited inspection procedures and explicit restoration checks.
- Reviewed storage/vault private-path proposals against actual deployment callers, DNS resolution and cost; did not present every proposed private endpoint as deployed.

This case study draws on a workforce/operations platform I designed and implemented. Organization details and records are excluded. The public code makes selected patterns reproducible; the screenshots show a working local demonstration with fictional data. [Validation scope](docs/VALIDATION.md) separates that evidence from testing against the actual cloud service.

## Tools Used and What They Do

| Tool or service | What it does | Where it fits |
| --- | --- | --- |
| Terraform | Describe private service access and the selected resource relationships. | Actual source patterns plus default-Off public examples. |
| Azure Virtual Network, peering and NSGs | Connect and filter the intended network paths. | Azure network components, not application authorization. |
| Private endpoints and Azure Private DNS | Provide selected private service addresses and name resolution. | Architecture/reference components; existence and current activation require separate evidence. |
| Azure CLI, PowerShell and DNS lookup utilities | Inspect resource state and check resolution from the intended caller. | Operating tools; a laptop result does not prove a hosted caller’s path. |
| Microsoft Entra ID and service data roles | Authorize access after the network path is available. | Separate identity layer; a reachable private IP grants no data permission. |
| Python and Terraform mock tests | Run the public decision model and infrastructure checks. | Local validation, not a packet test or cloud deployment. |

The recorded nonproduction endpoint cost pause means private paths must be restored before the affected tests resume. These examples do not recreate them, and the manual-only workflow does not activate paid networking.

## Step by Step

A private Blob endpoint and private DNS path in your own VNet, with an explicit DNS/network test.

[Open the standalone build guide](docs/BUILD-YOUR-OWN.md) or follow the same complete instructions below.

Start with a new folder, your own files and your own accounts. The numbered steps below describe the build; no portfolio repository checkout is required. The existing implementation/evidence elsewhere in this repository is a separate reference, not a claim that your new build has already passed.

### Prerequisites

Azure subscription; permission for a storage account, VNet, private endpoint and DNS zone; an authorized client inside that VNet or a connected network. Endpoints and any test VM have ongoing charges.

Use Bash on Linux/macOS/WSL for Bash blocks and PowerShell for PowerShell blocks. Select the tool versions supported by the official sources below, record the versions you actually install and retain generated dependency locks. Cloud resources, scanner downloads, logs and external AI calls can create costs; review the stated scope before enabling them.

### Create your project folder

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

### Step 1 — Choose your names and client path

**Where:** Your design notes.

Choose a unique lowercase storage account name, one VNet/subnet and an isolated resource group. Identify the client that will resolve and call the storage service; Cloud Shell on a public path is not automatically inside your VNet.

**Check before continuing:** You can draw client → DNS → private endpoint → Blob service.

### Step 2 — Create the storage account and private container

**Where:** Azure Portal → Storage accounts → Create.

Create a StorageV2 account with your selected redundancy and TLS minimum, disable anonymous Blob access and Shared Key, and create a private container named documents. Keep public network access closed once the private caller path is ready. Before using the Portal container interface, establish the intended test identity's scoped Blob data role; management ownership alone is not a data-plane grant.

**Check before continuing:** The account and container exist; anonymous data access is not enabled.

### Step 3 — Create your network and endpoint

**Where:** Azure Portal → Virtual networks; then Storage account → Networking → Private endpoints.

Create your VNet and endpoint subnet if you do not already have an isolated one. Add a private endpoint for the Blob subresource, selecting your account and that subnet; note the endpoint private IP.

**Check before continuing:** The endpoint connection is Approved and the private NIC has an address in your selected subnet.

### Step 4 — Connect private DNS

**Where:** Private endpoint creation / Private DNS zones.

Enable integration with privatelink.blob.core.windows.net and link that zone to the client VNet. Confirm the account A record matches the endpoint NIC rather than creating an unrelated public DNS record.

**Check before continuing:** Your client VNet is linked and the Blob private record matches the NIC.

### Step 5 — Test from the intended client

**Where:** Inside your client VM or connected network.

Resolve the ordinary ACCOUNT.blob.core.windows.net name and verify the resolved private IP. Test HTTPS and then a permitted Blob operation using Entra authentication with a separately assigned data role; a port connection alone is not an authorization test.

```powershell
Resolve-DnsName -Name "YOUR_ACCOUNT.blob.core.windows.net"
Test-NetConnection -ComputerName "YOUR_ACCOUNT.blob.core.windows.net" -Port 443
```

**Check before continuing:** DNS, network reachability and data authorization have three separately recorded outcomes.

### Step 6 — Test denial and finish

**Where:** An off-network test client and Azure Portal.

Check that the unapproved public client cannot read the private container, without opening the account to troubleshoot. Capture your DNS/endpoint/authorization evidence, then delete only your lab endpoint, DNS link, account and any lab compute after reviewing retained data.

**Check before continuing:** The intended private caller works, the unapproved caller is denied, and remaining costs are accounted for.

### Verification and your own screenshots

| Evidence | What to record | Your result |
| --- | --- | --- |
| New build | Your own files/resource settings and tool versions | Not yet recorded |
| Working path | The actual successful request, configuration or recovery result | Not yet recorded |
| Failure boundary | A meaningful denied, malformed, stale or failed case | Not yet recorded |
| Recovery / cleanup | What you restored or removed and what remains billed | Not yet recorded |

Capture your own architecture/configuration, one working result and one failure/recovery result. Keep tokens, credentials, personal records and private identifiers out of public screenshots. The architecture diagram explains the design; record your own results rather than treating it as execution evidence.

### Troubleshooting order

1. Confirm the named file, working directory and selected tool/interpreter.
2. Check the exact input and resource/account selected for the failing step.
3. Separate identity permission, network/DNS reachability and application validation.
4. Keep the actual error and reconcile an unknown write outcome before repeating it; do not widen access or repeat paid operations blindly.

The numbered steps describe a build procedure. Local syntax checks, an accepted API request, a completed hosted operation and a human verification are different evidence levels; fill in the verification table with what you actually observed.

### Official implementation references

- [learn.microsoft.com — storage-private-endpoints](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [learn.microsoft.com — private-endpoint-dns](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)

The walkthrough layout follows the prerequisites → creation/configuration → test → verification → troubleshooting → cleanup pattern of the [Splunk project reference](https://github.com/davidharris6/splunk-siem-log-analysis). Its Splunk-specific settings are not copied into unrelated projects.

<details>
<summary>Reference: how the existing platform implementation operates</summary>

A short walkthrough of the process, with technical instructions and evidence limits in the sections below.

1. **Identify callers and protected services** — List who must reach the website, database and file store. Separate user access from deployment, monitoring and recovery access.

2. **Define the approved network paths (Terraform)** — Use separate network areas and explicit connections for the intended services. Additional private connections remain optional in the public example.

3. **Check names and permissions (Private DNS and service roles)** — Confirm that each caller finds the intended service address and can reach it. Then check identity permissions, because network connectivity alone does not grant data access.

4. **Review before changing access** — Test required callers before restricting or expanding a live connection. Keep the cost, recovery path and any unimplemented network options visible.

</details>

## Architecture

1. **Internet** → **Public application and identity**.
2. Shared-services hub exchanges information with Workload spoke (VNet peering).
3. **Public application and identity** → **Application integration subnet**.
4. **Workload spoke** → **Application integration subnet**.
5. **Application integration subnet** → **Optional private endpoint (HTTPS and identity)**.
6. **Private DNS zone and VNet link** → **Optional private endpoint**.
7. **Optional private endpoint** → **Existing private data service**.
8. Reviewed deployment caller has a conditional/reference connection to Shared-services hub.

[View the illustrated project overview](../../docs/diagrams/architecture.svg).

## What Was Built

| Component | Role in plain words | Implementation |
| --- | --- | --- |
| Hub and workload spoke | Separate shared connectivity from workload-owned address space. | [View code](infra/main.tf) |
| Reciprocal VNet peering | Connect the two VNets without claiming automatic routing through another connected network. | [View code](infra/main.tf) |
| Delegated application subnet | Provide the integration subnet pattern used by Functions Flex. | [View code](infra/main.tf) |
| Endpoint subnet and management NSG | Reserve private-service placement and block management ingress ports. | [View code](infra/main.tf) |
| Optional private endpoint | Target a separately managed service and linked DNS zone; default is Off. | [View code](infra/variables.tf) |
| Network policy reference | Test fictional address containment, DNS decisions and allowed/denied traffic in a model. | [View code](lab/domain.py) |

## Proof It Works

**Recorded checks:** 11 unit tests passed · 6 demonstration checks passed · 2 Terraform tests using simulated cloud responses passed.

These are dated results for this reference implementation, not live Azure/AWS deployment claims. [Test record](docs/validation-results.json) · [Evidence and limitations](docs/VALIDATION.md)

### 1. The address plan rejects overlap

The reference accepts disjoint hub/spoke ranges and rejects overlapping networks, overlapping subnets or a subnet outside its spoke.

Run from the repository root:

```bash
python -B -m unittest discover -s tests -p test_domain.py -v
```

**What to look for:** The address-plan tests accept valid ranges and reject overlap or escaped subnets.

### 2. DNS and access remain separate decisions

The model returns a private address only when both the endpoint and private-zone link are present. Public resolution does not itself grant document access.

Run from the repository root:

```bash
python -B -m lab demo
```

**What to look for:** The JSON report includes modeled DNS and allowed/denied traffic checks. It does not probe Azure.

### 3. The endpoint remains an explicit choice

Mock Terraform plans confirm no endpoint by default and reject enabling it without the required target/DNS inputs.

Run from the repository root:

```bash
terraform -chdir=infra test -filter=tests/foundation.tftest.hcl
```

**What to look for:** Both mock plans pass: an endpoint is absent by default and missing integration inputs are rejected.

### 4. Visible results

The dashboard runs the same domain code as the CLI. Desktop/mobile rendering, all three tabs, rerunning the demonstration, cross-origin write rejection and unlisted-file rejection were checked. The screenshots are captured from those runs.

Expected access denials are successful negative tests. Cloud permissions, network connectivity and provider integrations need their own acceptance evidence.

## Security Practices

- Network examples use fictional ranges and contain no existing subscription IDs or backend state.
- The endpoint is Off by default. No firewall, DNS cutover or cloud network closure is performed by this project.
- The dashboard is a policy model, not a live Azure NSG or connectivity test. Private routing still needs service authentication and caller verification.

State, saved Terraform plans, private inputs and credentials are excluded through [`.gitignore`](.gitignore). The existing validation workflow is manual-only and has no cloud deployment permission.

## Run It Locally

The [command reference](docs/COMMANDS.md) includes prerequisites, Windows equivalents, focused checks and evidence notes.

Requires Python 3.12 or newer. The default demonstration uses the Python standard library. Run inside a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -B -m unittest discover -s tests -v
python -B -m lab demo
python -B -m lab serve --port 8011
```

On Windows, use `.venv\Scripts\Activate.ps1` instead of the `source` command, or run `.venv\Scripts\python.exe` directly. Open [the local workbench](http://127.0.0.1:8011), choose **Run demonstration**, then review **Validation** and **Evidence**. Stop with Ctrl+C. No cloud login, employee data or paid API request is required.

## Terraform Infrastructure

Parameterized hub/spoke networking, peering configured in both directions, a delegated application subnet, a separate endpoint subnet, management-ingress restrictions and an opt-in endpoint for an existing service.

See the [Terraform code and validation steps](infra/README.md), [input example](infra/example.tfvars.example) and [mock plan tests](infra/tests). Cloud commissioning and any paid resources remain separate from the local demonstration.

Validate the infrastructure source without creating cloud resources:

```bash
cd infra
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform test
```

The tests use mock providers. Example inputs are placeholders, not deployment-ready values. Review the [integration boundaries and cost notes](infra/README.md) before any separate cloud commissioning.

## Scaling and Tradeoffs

Plan non-overlapping addresses before adding spokes. Keep DNS ownership, shared-service placement and deployment/recovery paths explicit. Private endpoints add cost and operating dependencies; they should follow a verified caller matrix.

See [strengths, weaknesses and tradeoffs](docs/SCALING.md) for the detailed decisions.

## Skills Demonstrated

- Azure hub-and-spoke networking
- VNet peering and subnet delegation
- NSGs and private endpoint design
- DNS and caller-path troubleshooting
- Reusable Terraform and mock plan validation

## Troubleshooting Lessons

Removing a nonproduction private path required more than checking its environment label. Production used a shared storage account through a separate endpoint that had to remain intact. [Read the incident, evidence and verification](docs/LESSONS-LEARNED.md).

## DNS Configuration Walkthrough

Configure the private zone, link the caller’s VNet, associate the endpoint and verify its A record. The [DNS walkthrough](docs/DNS-WALKTHROUGH.md) includes Terraform excerpts, read-only CLI/DNS commands, portal steps and troubleshooting; it also contrasts external public CNAME records with Azure Private DNS and records the nonproduction cost-pause boundary.

## Project Guides

| Guide | What you will find |
| --- | --- |
| [Command reference](docs/COMMANDS.md) | Copy the commands, understand their purpose and check expected results |
| [Implementation walkthrough](docs/WALKTHROUGH.md) | Follow the processing path and code |
| [DNS configuration walkthrough](docs/DNS-WALKTHROUGH.md) | Zones, VNet links, endpoint records, commands, portal steps and troubleshooting |
| [Architecture](docs/ARCHITECTURE.md) | Understand service and identity boundaries |
| [Terraform](infra/README.md) | Read the resource map, input examples and integration steps |
| [Validation evidence](docs/VALIDATION.md) | See the test dates, results and limits |
| [Operations and troubleshooting](docs/OPERATIONS.md) | Diagnose failures and recover safely |
| [Security and privacy](SECURITY.md) | Review access, secrets and publication controls |
| [Scaling and tradeoffs](docs/SCALING.md) | Understand the costs of each design choice |
| [References](docs/REFERENCES.md) | See technical sources and presentation inspiration |

## Repository Map

```text
infra/               Terraform source, example inputs and mock plan tests
lab/                 Working reference implementation and loopback dashboard
tests/               Positive, negative and recovery cases
docs/                Architecture, walkthrough, evidence and operating guide
.github/workflows/   Manual-only contract validation; no cloud deployment
```

## Cost and Cleanup

The default local demo creates only temporary local state and makes no paid calls. Cloud examples are separate opt-in source and can create billable resources if an operator applies them. No automated deployment or destruction is configured. Use `git status --short --ignored` before cleanup; remove only your own `.venv` or disposable lab output. Never copy real state files, tokens or employee documents into this repository.
