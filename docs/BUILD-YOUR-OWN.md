# Build your own from scratch: Azure Hub Spoke Networking

Your own Azure hub, spoke, client subnet and two peering links, with a documented route/access test.

Start with a new folder, your own files and your own accounts. The numbered steps below describe the build; no portfolio repository checkout is required. The existing implementation/evidence elsewhere in this repository is a separate reference, not a claim that your new build has already passed.

## Prerequisites

Azure subscription with permission to create a dedicated resource group and networks; Azure CLI; Terraform; a non-overlapping address plan. A VM/Bastion/firewall is additional paid scope, not part of the definition below.

Use Bash on Linux/macOS/WSL for Bash blocks and PowerShell for PowerShell blocks. Select the tool versions supported by the official sources below, record the versions you actually install and retain generated dependency locks. Cloud resources, scanner downloads, logs and external AI calls can create costs; review the stated scope before enabling them.

## Create your project folder

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

## Step 1 — Draw your address and traffic plan

**Where:** Your editor.

Draw a hub at 10.60.0.0/16 and a spoke at 10.61.0.0/16, changing both if they overlap your existing networks. Write down which client should reach which destination and service port.

**Check before continuing:** The two ranges do not overlap and you have a specific allowed and denied traffic case.

## Step 2 — Create the network definition

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

## Step 3 — Select your Azure target and review the plan

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

## Step 4 — Inspect both peering directions

**Where:** Azure Portal → Virtual networks → each VNet → Peerings.

Open the hub and spoke and check that both links reach Connected. Inspect the client subnet and each VNet address range; do not infer working packets from a Connected label.

**Check before continuing:** Both links exist and their remote network IDs match your intended pair.

## Step 5 — Prove an actual path

**Where:** Your own lab client and destination, if you commission them.

Create isolated test clients only if you need packet proof, with no general internet administration rule. Test the selected service from the client, then inspect its effective routes and NSG rules; record DNS resolution separately.

**Check before continuing:** You have either real allowed/denied traffic evidence or an explicit declaration-only result, not a fabricated connectivity claim.

## Step 6 — Record evidence and remove the lab

**Where:** Your project folder and Azure Portal.

Save your diagram, reviewed plan, peering screenshots and actual test results. Run a destroy plan for this isolated Terraform state and remove only the reviewed lab resources; inventory separately created clients or addresses too.

**Check before continuing:** The cleanup inventory accounts for networks, clients and any retained billable resources.

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

- [learn.microsoft.com — virtual-network-peering-overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
- [developer.hashicorp.com — plan](https://developer.hashicorp.com/terraform/cli/commands/plan)

The walkthrough layout follows the prerequisites → creation/configuration → test → verification → troubleshooting → cleanup pattern of the [Splunk project reference](https://github.com/davidharris6/splunk-siem-log-analysis). Its Splunk-specific settings are not copied into unrelated projects.
