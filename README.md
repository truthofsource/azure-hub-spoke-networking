# Azure Hub-and-Spoke Networking and Shared Services

**Separate application networks while keeping shared connections organized.**

[Business problem](#the-business-problem) · [Solution](#the-solution) · [What was built](#what-was-built) · [Proof it works](#proof-it-works) · [Commands](docs/COMMANDS.md) · [Step by step](#step-by-step)

![Source topology and address plan](docs/images/01-topology.png)

## The Business Problem

The organization runs a production application, a separate test environment and shared engineering services. As these grow, each new database, worker or internal tool needs an agreed place in the network and a clear owner. Ad hoc connections can create overlapping addresses, unexpected access or dependencies that are difficult to understand during a change.

A test environment also needs room to evolve without putting live employee services at risk. Shared services should be reusable, while their costs and access remain distinguishable from the applications they support. Buying a firewall, gateway or additional DNS service before there is a proven requirement adds ongoing expense.

The business problem was to create an understandable foundation for growth: separate environments, deliberate connections, clear ownership and space for future services without commissioning every optional component immediately.

## The Solution

Use a central network, called a hub, and a separate application network, called a spoke. Define the connections and address ranges explicitly, reserve space for future services, and keep shared engineering services separately owned. Network connections, name lookup and data permissions are checked separately.

**Business outcome:** Provide an organized network foundation that can grow without assuming every connected system can access every other system.

### Actual implementation

- Production hub: **10.30.0.0/16**, peered in both directions with the production application spoke, **10.40.0.0/16**.
- Production integration subnet: **10.40.1.0/24**; endpoint subnet: **10.40.2.0/24**; future integration reservation: **10.40.3.0/24**.
- Separate nonproduction application network: **10.20.0.0/16**, using the reusable module.
- Separate shared engineering-services VNet: **10.50.0.0/20**, owned by a different infrastructure root. The selected source does not define a production peering for this VNet.
- Both production peerings allow VNet access and keep forwarded traffic, gateway transit and remote-gateway use **Off**.
- Firewall, resolver and gateway subnet reservations do **not** create those services.

The project includes actual selected Terraform with example resource names, plus a small new offline topology viewer and address-policy checks. This is evidence based on the source code, not a fresh Azure inventory or live packet test. [Source mapping](docs/SOURCE-MAP.md).

## Tools Used and What They Do

| Tool or service | What it does | Where it fits |
| --- | --- | --- |
| Terraform | Describe shared network placement and caller paths and the selected resource relationships. | Actual source patterns plus default-Off public examples. |
| Azure Virtual Network, peering and NSGs | Connect and filter the intended network paths. | Azure network components, not application authorization. |
| Private endpoints and Azure Private DNS | Provide selected private service addresses and name resolution. | Architecture/reference components; existence and current activation require separate evidence. |
| Azure CLI, PowerShell and DNS lookup utilities | Inspect resource state and check resolution from the intended caller. | Operating tools; a laptop result does not prove a hosted caller’s path. |
| Microsoft Entra ID and service data roles | Authorize access after the network path is available. | Separate identity layer; a reachable private IP grants no data permission. |
| Python and Terraform mock tests | Run the public decision model and infrastructure checks. | Local validation, not a packet test or cloud deployment. |

The recorded nonproduction endpoint cost pause means private paths must be restored before the affected tests resume. These examples do not recreate them, and the manual-only workflow does not activate paid networking.

## Step by Step

Your own Azure hub, spoke, client subnet and two peering links, with a documented route/access test.

[Open the standalone build guide](docs/BUILD-YOUR-OWN.md) or follow the same complete instructions below.

Start with a new folder, your own files and your own accounts. The numbered steps below describe the build; no portfolio repository checkout is required. The existing implementation/evidence elsewhere in this repository is a separate reference, not a claim that your new build has already passed.

### Prerequisites

Azure subscription with permission to create a dedicated resource group and networks; Azure CLI; Terraform; a non-overlapping address plan. A VM/Bastion/firewall is additional paid scope, not part of the definition below.

Use Bash on Linux/macOS/WSL for Bash blocks and PowerShell for PowerShell blocks. Select the tool versions supported by the official sources below, record the versions you actually install and retain generated dependency locks. Cloud resources, scanner downloads, logs and external AI calls can create costs; review the stated scope before enabling them.

### Create your project folder

Choose a new folder name. These first commands create a blank project; an optional `git init` gives it its own history. Create parent directories in your editor when a later step introduces a nested file.

```bash
mkdir my-azure-hub-spoke-networking
cd my-azure-hub-spoke-networking
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

### Step 1 — Draw your address and traffic plan

**Where:** Your editor.

Draw a hub at 10.60.0.0/16 and a spoke at 10.61.0.0/16, changing both if they overlap your existing networks. Write down which client should reach which destination and service port.

**Check before continuing:** The two ranges do not overlap and you have a specific allowed and denied traffic case.

### Step 2 — Create the network definition

**Where:** Your new project folder.

Create main.tf below and substitute your own group name, region and owner tag. Each peering is a separate direction; this example does not add a firewall or make a hub a transit router.

Create **`main.tf`** with the following contents:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
variable "subscription_id" {
  type = string
}
resource "azurerm_resource_group" "lab" {
  name     = "rg-my-network-lab"
  location = "eastus2"
  tags     = { environment = "lab", owner = "your-team" }
}
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-my-hub"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.60.0.0/16"]
}
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-my-spoke"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.61.0.0/16"]
}
resource "azurerm_subnet" "client" {
  name                 = "clients"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.61.1.0/24"]
}
resource "azurerm_virtual_network_peering" "outbound" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.lab.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}
resource "azurerm_virtual_network_peering" "return" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.lab.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}
```

**Check before continuing:** The folder contains a readable definition for both VNets, the subnet and both links.

### Step 3 — Select your Azure target and review the plan

**Where:** Bash / WSL terminal.

Sign in to your own subscription, set TF_VAR_subscription_id to its ID, then initialize, validate and save a plan. Inspect that plan for only your new lab resources before applying it.

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
export TF_VAR_subscription_id="YOUR_SUBSCRIPTION_ID"
terraform init
terraform fmt
terraform validate
terraform plan -out=network.tfplan
terraform show network.tfplan
# After checking the target and costs:
terraform apply network.tfplan
```

**Check before continuing:** Validation succeeds and the saved plan contains no unrelated replacement/deletion.

### Step 4 — Inspect both peering directions

**Where:** Azure Portal → Virtual networks → each VNet → Peerings.

Open the hub and spoke and check that both links reach Connected. Inspect the client subnet and each VNet address range; do not infer working packets from a Connected label.

**Check before continuing:** Both links exist and their remote network IDs match your intended pair.

### Step 5 — Prove an actual path

**Where:** Your own lab client and destination, if you commission them.

Create isolated test clients only if you need packet proof, with no general internet administration rule. Test the selected service from the client, then inspect its effective routes and NSG rules; record DNS resolution separately.

**Check before continuing:** You have either real allowed/denied traffic evidence or an explicit declaration-only result, not a fabricated connectivity claim.

### Step 6 — Record evidence and remove the lab

**Where:** Your project folder and Azure Portal.

Save your diagram, reviewed plan, peering screenshots and actual test results. Run a destroy plan for this isolated Terraform state and remove only the reviewed lab resources; inventory separately created clients or addresses too.

**Check before continuing:** The cleanup inventory accounts for networks, clients and any retained billable resources.

### Verification and your own screenshots

| Evidence | What to record | Your result |
| --- | --- | --- |
| New build | Your own files/resource settings and tool versions | Not yet recorded |
| Working path | The actual successful request, configuration or recovery result | Not yet recorded |
| Failure boundary | A meaningful denied, malformed, stale or failed case | Not yet recorded |
| Recovery / cleanup | What you restored or removed and what remains billed | Not yet recorded |

Capture your own architecture/configuration, one working result and one failure/recovery result. Keep tokens, credentials, personal records and private identifiers out of public screenshots. Existing portfolio images are references, not evidence that you performed these steps.

### Troubleshooting order

1. Confirm the named file, working directory and selected tool/interpreter.
2. Check the exact input and resource/account selected for the failing step.
3. Separate identity permission, network/DNS reachability and application validation.
4. Keep the actual error and reconcile an unknown write outcome before repeating it; do not widen access or repeat paid operations blindly.

The numbered steps describe a build procedure. Local syntax checks, an accepted API request, a completed hosted operation and a human verification are different evidence levels; fill in the verification table with what you actually observed.

### Official implementation references

- [learn.microsoft.com — virtual-network-peering-overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
- [developer.hashicorp.com — plan](https://developer.hashicorp.com/terraform/cli/commands/plan)

The walkthrough layout follows the prerequisites → creation/configuration → test → verification → troubleshooting → cleanup pattern of the [Splunk project reference](https://github.com/davidharris6/splunk-siem-log-analysis). Its Splunk-specific settings are not copied into unrelated projects.

<details>
<summary>Reference: how the existing platform implementation operates</summary>

A short walkthrough of the process, with technical instructions and evidence limits in the sections below.

1. **Assign a purpose to each network** — Use a central hub for selected shared connectivity and separate networks for application workloads. Give each network a clearly owned address range.

2. **Define the intended connections (Terraform)** — Describe the approved links and service areas in reusable setup code. Reserved space for a future service does not mean that service is deployed.

3. **Check the full access path (Private DNS, routes and roles)** — Review routing, name lookup and identity permissions separately. Connecting two networks does not automatically grant access to every service.

4. **Validate before expanding** — The local checks test example address plans and proposed setup settings. A real expansion still needs caller checks, cost review and an agreed operating owner.

</details>

## Architecture

```mermaid
flowchart LR
  Hub[Production connectivity hub
10.30.0.0/16] <-->|Reciprocal peering
transit controls Off| Spoke[Production application spoke
10.40.0.0/16]
  Hub --> Reserved[Reserved subnets
Firewall / Resolver / Gateway
services deferred]
  Spoke --> App[Functions integration subnet]
  Spoke --> Endpoint[Workload endpoint subnet]
  App -->|Existing private data path| Data[SQL / document services]
  DNS[Explicit private DNS zone / VNet links] --> App
  NP[Separate nonproduction network
10.20.0.0/16]
  Eng[Separate engineering-services VNet
10.50.0.0/20]
  Shared[Shared resource ownership
registry / operational workspace / security workspace]
```

The isolated boxes are deliberate: the selected source does not prove a route from every network to every other network. Shared workspaces and registry ownership do not place those managed services inside a hub subnet. [Architecture detail](docs/ARCHITECTURE.md).

## What Was Built

| Component | Purpose | Source |
| --- | --- | --- |
| Reusable network module | Resource group, VNet, delegated Functions integration and endpoint subnet | [Module](infra/modules/network/) |
| Production hub and spoke | Actual address plan, reservations and peering configured in both directions | [Hub](infra/modules/foundation/hub.tf) · [Spoke](infra/modules/foundation/network.tf) |
| Default-Off public wrapper | Make local validation reproducible without selecting cloud resources by default | [Root](infra/main.tf) |
| Nonproduction network reference | Show environment-specific inputs to the same module | [Source](reference/nonproduction/network.tf) |
| Shared engineering VNet reference | Show separate network ownership and reserved managed-service subnets | [Source](reference/shared-services/network.tf) |
| Shared monitoring boundaries | Keep operational and security workspaces/ingestion distinct | [References](reference/monitoring/) |
| Existing private data/DNS reference | Explain SQL and document endpoint placement and explicit DNS links | [References](reference/dns/) |
| Offline topology checks | Reject overlapping/escaped address plans and avoid inferred peering/transit | [Model](lab/topology.py) |

The `reference/` files are source excerpts with unresolved owning-root inputs; they are not an extra independently deployable stack. The executable Terraform root creates only the selected network foundation if deliberately enabled, and does not deploy database, registry, monitoring, Firewall, resolver or gateway services.

## Proof It Works

### 1. Validate the address plan

```bash
python -B -m unittest discover -s tests -v
python -B -m lab.topology
```

**Look for:** valid disjoint networks, contained non-overlapping subnets, refusal of duplicate/unknown peerings and explicit separation of the engineering VNet. Tests compare modeled prefixes and transit settings with the copied source.

### 2. Do not assume hub transit or DNS inheritance

The model checks that reciprocal production peering is defined. A fictional second spoke peered with the hub does not become directly peered with the first spoke. The SQL DNS reference links the client VNet explicitly; peering does not copy the link to the hub.

![Offline boundary checks](docs/images/02-checks.png)

These declaration checks are not a route-engine simulation. They do not evaluate NSGs, effective routes, service firewalls, endpoint state or application authorization. [Routing and access](docs/ROUTING-AND-DNS.md).

### 3. Validate Terraform without deploying it

```bash
terraform -chdir=infra init -backend=false -input=false
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
terraform -chdir=infra test
```

**Look for:** three cases using simulated responses verify default-Off selection, the actual address/reservation plan and both peerings' access/transit flags. No Azure plan/apply or resource lookup occurs.

### 4. Inspect the local topology

```bash
python -B scripts/preview.py
```

Open [the local reference viewer](http://127.0.0.1:8137). Switch between Network topology, Boundary checks and Shared services. The browser screenshots show this local reference, not Azure Portal. Ctrl+C stops it. [Dated validation](docs/VALIDATION.md).

## Where Shared Services Belong

| Service | Suitable ownership/placement | What to avoid assuming |
| --- | --- | --- |
| Transit, gateway, resolver | Connectivity ownership; dedicated reserved subnets when actually commissioned | An empty named subnet is an active service |
| Backstage/engineering tooling | Dedicated service boundary, possibly a services VNet/subscription | Every tool belongs in the transit hub |
| Operational workspace | Shared operational resource group and reader/ingestion controls | A Log Analytics workspace is a VM in the hub VNet |
| Security workspace | Separate security access, retention and selected ingestion | All application logs should automatically enter Sentinel |
| Registry | Shared platform ownership, scoped build/pull identities | Hub placement makes a public registry endpoint private |
| SQL and employee documents | Workload-owned data and authorization boundaries | Shared connectivity implies shared data permissions |

The implemented source has multiple infrastructure roots and network meanings of “hub.” A separate services VNet/subscription can reduce coupling as ownership and risk grow; it is a design decision, not a universal requirement. [Placement rationale](docs/SHARED-SERVICES.md).

## Operations and Change Safety

Before a real network change: identify the owning state/root, compare effective routes and actual DNS from each caller, verify identity/service policy, review cost and rollback, then inspect the exact Terraform plan. Preserve required deployment and recovery routes. A no-change plan is not application acceptance, and a passing connection does not prove authorization to another person's records.

The public root has no remote backend, cloud credentials or commissioned input file. Do not apply its example names/default-Off wrapper to an adopted live state. No network, endpoint, peering, service power state or paid tier was changed for this portfolio.

## Scaling and Tradeoffs

Hub-and-spoke centralizes connectivity ownership and reserves expansion capacity, but adds address, routing, DNS and permission coordination. Peering can incur traffic charges; firewalls, gateways and resolvers introduce their own running costs. Scale from measured traffic, regional needs, address growth and operating ownership, not from a diagram alone. [Scaling and tradeoffs](docs/SCALING.md).

## Troubleshooting Lessons

A shared resource’s subscription label did not identify all its consumers. The endpoint cost pause preserved production’s independent DNS and private-access path. [Read the incident, evidence and verification](docs/LESSONS-LEARNED.md).

## Project Guides

| Guide | Purpose |
| --- | --- |
| [Architecture](docs/ARCHITECTURE.md) | Actual topology and limits of what the evidence proves |
| [Address plan](docs/ADDRESS-PLAN.md) | CIDRs, subnets, reservations and growth |
| [Shared-service placement](docs/SHARED-SERVICES.md) | Hub versus services VNet/subscription |
| [Private DNS configuration walkthrough](https://github.com/truthofsource/azure-private-networking/blob/main/docs/DNS-WALKTHROUGH.md) | Service zones, VNet links, endpoint records, read-only checks and troubleshooting in the companion project |
| [Routing and DNS](docs/ROUTING-AND-DNS.md) | Peering, transit, private resolution and identity |
| [Operations](docs/OPERATIONS.md) | Caller matrix, troubleshooting and change/rollback procedure |
| [Commands and ClickOps](docs/COMMANDS.md) | Local validation and read-only inspection examples |
| [Scaling](docs/SCALING.md) | Strengths, weaknesses, costs and growth |
| [Source mapping](docs/SOURCE-MAP.md) | Actual files and public adaptations |
| [Validation](docs/VALIDATION.md) | Local proof and remaining hosted boundaries |
| [Terraform](infra/README.md) | Module layout and activation guard |

Related: [Private application/data networking](https://github.com/truthofsource/azure-private-networking) focuses on caller/DNS/access policy; [Backstage hosting](https://github.com/truthofsource/azure-backstage-developer-portal) covers the engineering service running on its selected VM profile.
