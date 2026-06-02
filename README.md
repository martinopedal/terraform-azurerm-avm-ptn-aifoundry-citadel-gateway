# Terraform AVM Pattern Module: AI Foundry Citadel Gateway

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**PRIVATE REPOSITORY** — This module is a Terraform port of the [Azure-Samples/ai-hub-gateway-solution-accelerator](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator) @ branch `citadel-v1` (the "Citadel Governance Hub" — Microsoft's reference implementation of Layer 1 of the Foundry Citadel Platform).

## Overview

This module deploys the **Citadel Governance Hub** — a centralized AI Gateway that provides:

- **API Management (APIM)** with AI-specific policies (token limits, content filtering, PII redaction, semantic caching)
- **Multi-LLM backend orchestration** with load balancing, failover, and priority routing
- **Microsoft Foundry** (Cognitive Services + Hub + Model Deployments) for Azure OpenAI, DeepSeek, Phi-4, and embeddings
- **Usage ingestion pipeline** for cost attribution and analytics (Event Hub → Logic App → Cosmos DB)
- **API Center** for governance and discovery
- **Private networking** with bring-your-own VNet support
- **Managed Redis** (opt-in) for semantic caching

## Status

⚠️ **WORK IN PROGRESS** — This module is under active development.

- ✅ **Phase 1**: Inventory + skeleton (completed)
- 🚧 **Phase 2**: Core hub (networking, identities, monitoring, Key Vault, Foundry, Cosmos) — IN PROGRESS
- 🔜 **Phase 3**: AI Gateway (APIM + gateway core + API Center)
- 🔜 **Phase 4**: Usage ingestion + Redis

## Features

- **AzAPI-first** for Foundry, APIM, API Center, Event Hub, Logic App (tracks ARM API surface)
- **Azure Verified Modules (AVM)** for standard resources (VNet, Key Vault, Log Analytics, Cosmos DB, Storage, Redis)
- **Bring-your-own VNet** support with existing subnet references
- **Private DNS zone integration** for private endpoints
- **Entra ID authentication** (optional, configurable)
- **Managed Redis** (opt-in, default: `false`)

## Prerequisites

1. **Entra ID App Registration** (if `entra_auth = true`):
   - Create an app registration in Microsoft Entra ID
   - Store the client secret in your Key Vault (or provide via `entra_client_secret` variable)
   - See: [bicep/infra/entra-id-setup/README.md](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1/bicep/infra/entra-id-setup) in the source accelerator

2. **Private DNS Zones** (if `use_existing_vnet = true`):
   - Provision Private DNS zones for:
     - `privatelink.openai.azure.com`
     - `privatelink.cognitiveservices.azure.com`
     - `privatelink.services.ai.azure.com`
     - `privatelink.vaultcore.azure.net`
     - `privatelink.servicebus.windows.net`
     - `privatelink.documents.azure.com`
     - `privatelink.blob.core.windows.net`
     - `privatelink.file.core.windows.net`
     - `privatelink.table.core.windows.net`
     - `privatelink.queue.core.windows.net`
     - `privatelink.azure-api.net`
     - `privatelink.redis.azure.net` (if `enable_managed_redis = true`)
   - Link zones to your VNet
   - Provide zone resource IDs via `existing_private_dns_zones` variable

## Usage

```hcl
module "citadel_gateway" {
  source = "martinopedal/terraform-azurerm-avm-ptn-aifoundry-citadel-gateway"

  environment_name = "dev"
  location         = "eastus"

  # Networking
  use_existing_vnet = false
  vnet_address_prefix = "10.170.0.0/24"

  # AI Foundry instances
  ai_foundry_instances = [
    {
      name                     = "aif-primary"
      location                 = "eastus"
      custom_sub_domain_name   = "citadel-primary"
      default_project_name     = "citadel-governance-project"
      network_injection_enabled = true
    }
  ]

  # AI Foundry model deployments
  ai_foundry_models_config = [
    {
      name            = "gpt-4o"
      publisher       = "OpenAI"
      version         = "2024-11-20"
      sku             = "GlobalStandard"
      capacity        = 100
      retirement_date = "2026-09-30"
      aiservice_index = 0
    }
  ]

  # Feature flags
  enable_managed_redis = false
  entra_auth           = true

  # Entra ID
  entra_client_id = "00000000-0000-0000-0000-000000000000"

  # Tags
  tags = {
    Environment = "Development"
    Project     = "Citadel"
  }
}
```

See [`examples/default/`](./examples/default/) for a complete example.

## Inputs

See [`variables.tf`](./variables.tf) for the full list of input variables.

### Key Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `environment_name` | Name of the environment (used to generate unique resource names) | `string` | n/a | yes |
| `location` | Primary Azure region | `string` | n/a | yes |
| `use_existing_vnet` | Use an existing VNet instead of creating a new one | `bool` | `false` | no |
| `ai_foundry_instances` | AI Foundry instances configuration | `list(object)` | `[]` | yes |
| `ai_foundry_models_config` | AI Foundry model deployments | `list(object)` | `[]` | yes |
| `enable_managed_redis` | Enable Azure Managed Redis for semantic caching | `bool` | `false` | no |
| `entra_auth` | Enable Entra ID authentication | `bool` | `true` | no |

## Outputs

See [`outputs.tf`](./outputs.tf) for the full list of outputs.

## Architecture

See [`RESOURCE_INVENTORY.md`](./RESOURCE_INVENTORY.md) for the complete resource mapping from Bicep to Terraform.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.12.0, < 2.0 |
| azurerm | ~> 4.0 |
| azapi | ~> 2.0 |
| random | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.0 |
| azapi | ~> 2.0 |
| random | ~> 3.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vnet | Azure/avm-res-network-virtualnetwork | ~> 0.7.0 |
| log_analytics | Azure/avm-res-operationalinsights-workspace | ~> 0.4.0 |
| key_vault | Azure/avm-res-keyvault-vault | ~> 0.9.0 |
| cosmos_db | Azure/avm-res-documentdb-databaseaccount | ~> 0.5.0 |
| storage_account | Azure/avm-res-storage-storageaccount | ~> 0.14.0 |
| managed_redis | Azure/avm-res-cache-redis | ~> 0.3.0 |

## Contributing

This module is maintained by Martin Opedal. Contributions are welcome via pull requests.

## License

MIT License. See [`LICENSE`](./LICENSE) for details.

## Acknowledgments

This module is a Terraform port of the [Azure-Samples/ai-hub-gateway-solution-accelerator](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator) @ branch `citadel-v1`, developed by Microsoft.
