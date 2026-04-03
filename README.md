# ShopEase Infrastructure — Terraform

> Complete Azure infrastructure for the ShopEase e-commerce microservices platform, managed with Terraform and deployed via GitHub Actions.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                    Azure Resource Group (per env)                     │
│                                                                      │
│  ┌────────────┐  ┌────────────────────────────────────────────────┐  │
│  │    ACR      │  │       Container Apps Environment               │  │
│  │ (Registry)  │  │                                                │  │
│  └─────┬──────┘  │  ┌──────────┐  ┌──────────┐  ┌────────────┐  │  │
│        │         │  │ frontend │  │api-gateway│  │user-service│  │  │
│        │         │  │ :80 ext  │  │:3000 ext  │  │:3001 int   │  │  │
│        │         │  └──────────┘  └──────────┘  └────────────┘  │  │
│        │         │  ┌────────────┐ ┌────────────┐ ┌────────────┐ │  │
│        │         │  │product-svc │ │ order-svc  │ │notif-svc   │ │  │
│        │         │  │:3002 int   │ │:3003 int   │ │:3004 int   │ │  │
│        │         │  └────────────┘ └────────────┘ └────────────┘ │  │
│        │         └────────────────────────────────────────────────┘  │
│        │                                                             │
│  ┌─────┴──────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │ Key Vault  │  │Service Bus │  │Blob Storage│  │App Insights  │  │
│  │ (secrets)  │  │(messages)  │  │ (images)   │  │(telemetry)   │  │
│  └────────────┘  └────────────┘  └────────────┘  └──────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

## Azure Resources (per environment)

| Resource | Naming | Purpose |
|---|---|---|
| Resource Group | `shopease-{env}-rg` | Isolation boundary |
| Container Registry | `shopease{env}acr` | Docker image storage |
| Log Analytics | `shopease-{env}-logs` | Centralized logging |
| Application Insights | `shopease-{env}-insights` | APM & telemetry |
| Key Vault | `shopease-{env}-kv` | Secrets management |
| Service Bus | `shopease-{env}-bus` | Async messaging (order-notifications queue) |
| Storage Account | `shopease{env}stor` | Blob storage (product-images container) |
| Container Apps Env | `shopease-{env}-env` | Managed serverless container platform |
| Container Apps ×6 | `{service-name}` | Microservices (frontend, api-gateway, user/product/order/notification-service) |

## Environments

| Environment | Triggered By | Replicas | CPU | Memory |
|---|---|---|---|---|
| `dev` | Push to `main` | 0–1 | 0.25 | 0.5Gi |
| `qa` | Push to `release/**` | 0–2 | 0.25 | 0.5Gi |
| `uat` | Push to `release/**` | 1–3 | 0.5 | 1Gi |
| `prod` | Manual (requires confirmation) | 1–5 | 0.5 | 1Gi |
| `demo` | Manual | 0–1 | 0.25 | 0.5Gi |

## Repository Structure

```
.github/workflows/
├── terraform.yml          # Reusable workflow (plan → apply)
├── deploy-dev.yml         # Dev pipeline
├── deploy-qa.yml          # QA pipeline
├── deploy-uat.yml         # UAT pipeline
├── deploy-prod.yml        # Prod pipeline (manual + confirmation)
└── deploy-demo.yml        # Demo pipeline (manual)

infra/
├── modules/               # Reusable Terraform modules
│   ├── resource-group/
│   ├── acr/
│   ├── log-analytics/
│   ├── app-insights/
│   ├── keyvault/
│   ├── service-bus/
│   ├── storage/
│   ├── container-apps-env/
│   └── container-app/
└── shopease/              # Root module — wires everything together
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── provider.tf
    ├── data.tf
    ├── locals.tf
    └── environments/
        ├── dev.tfvars
        ├── qa.tfvars
        ├── uat.tfvars
        ├── prod.tfvars
        └── demo.tfvars
```

## Prerequisites

### 1. Terraform State Backend

Create an Azure Storage Account for remote state **before** running any pipeline:

```bash
# Create state resource group
az group create -n shopease-tfstate-rg -l eastus

# Create state storage account
az storage account create \
  -n shopeasetfstate \
  -g shopease-tfstate-rg \
  -l eastus \
  --sku Standard_LRS

# Create state container
az storage container create \
  -n tfstate \
  --account-name shopeasetfstate
```

### 2. Azure Service Principal

```bash
az ad sp create-for-rbac \
  --name "shopease-terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>
```

### 3. GitHub Secrets

Add these repository secrets in GitHub → Settings → Secrets:

| Secret | Description |
|---|---|
| `ARM_CLIENT_ID` | Service Principal App ID |
| `ARM_CLIENT_SECRET` | Service Principal Password |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID |
| `ARM_TENANT_ID` | Azure AD Tenant ID |
| `TF_STATE_RG` | State backend RG (`shopease-tfstate-rg`) |
| `TF_STATE_STORAGE` | State backend SA (`shopeasetfstate`) |
| `TF_STATE_CONTAINER` | State backend container (`tfstate`) |
| `TF_VAR_jwt_secret` | JWT signing secret |
| `TF_VAR_mongodb_uri_users` | MongoDB URI for user-service |
| `TF_VAR_mongodb_uri_products` | MongoDB URI for product-service |
| `TF_VAR_mongodb_uri_orders` | MongoDB URI for order-service |
| `TF_VAR_mongodb_uri_notifications` | MongoDB URI for notification-service |

> **Note**: Terraform automatically reads `TF_VAR_*` environment variables as input variables.

## Usage

### Deploy Dev (automatic)

Push to `main` with changes in `infra/` — the dev pipeline runs automatically.

### Deploy Production (manual)

1. Go to **Actions** → **Deploy ShopEase Infra - Prod**
2. Click **Run workflow**
3. Type `yes` in the confirmation field
4. Click **Run workflow**

### Local Development

```bash
cd infra/shopease

# Initialize (use dev backend)
terraform init \
  -backend-config="resource_group_name=shopease-tfstate-rg" \
  -backend-config="storage_account_name=shopeasetfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=shopease/shopease/dev/terraform.tfstate"

# Plan
terraform plan -var-file="environments/dev.tfvars"

# Apply
terraform apply -var-file="environments/dev.tfvars"
```

## Security

- **No secrets in code** — all sensitive values injected via GitHub Secrets / `TF_VAR_*`
- **Key Vault** stores runtime secrets; Container Apps access them via **Managed Identity**
- **Minimum TLS 1.2** enforced on Service Bus and Storage
- **Production deploy** requires manual trigger + typed confirmation
- **Terraform state** encrypted at rest in Azure Storage

## Related Repositories

| Repo | Purpose |
|---|---|
| [ShopEase (app)](https://github.com/PixelTech-Solutions/Cloud) | Application source code |
| [ShopEase_infra](https://github.com/PixelTech-Solutions/ShopEase_infra) | This repo — infrastructure as code |
