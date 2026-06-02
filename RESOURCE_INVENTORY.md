# Resource Inventory: Bicep → Terraform Port

**Source**: `Azure-Samples/ai-hub-gateway-solution-accelerator` @ branch `citadel-v1`  
**Target**: `martinopedal/terraform-azurerm-avm-ptn-aifoundry-citadel-gateway`

## Resource Mapping Table

| # | Bicep Module | Azure Resource Type | Terraform Approach | Provider | Module/Resource | API Version / Version | Phase |
|---|--------------|---------------------|-------------------|----------|-----------------|----------------------|-------|
| 1 | Resource Group | Microsoft.Resources/resourceGroups@2021-04-01 | azurerm | azurerm | azurerm_resource_group | N/A | 1 |
| 2 | DNS Zones | Microsoft.Network/privateDnsZones | azurerm | azurerm | azurerm_private_dns_zone | N/A | 2 |
| 3 | VNet (new) | modules/networking/vnet.bicep | AVM | azurerm | Azure/avm-res-network-virtualnetwork | ~> 0.7 | 2 |
| 4 | VNet (existing) | modules/networking/vnet-existing.bicep | Data Source | azurerm | data.azurerm_subnet | N/A | 2 |
| 5 | APIM Managed Identity | modules/security/managed-identity-apim.bicep | azurerm | azurerm | azurerm_user_assigned_identity | N/A | 2 |
| 6 | Usage Managed Identity | modules/security/managed-identity-usage.bicep | azurerm | azurerm | azurerm_user_assigned_identity | N/A | 2 |
| 7 | Log Analytics Workspace | modules/monitor/monitoring.bicep | AVM | azurerm | Azure/avm-res-operationalinsights-workspace | ~> 0.4 | 2 |
| 8 | Application Insights (APIM) | modules/monitor/monitoring.bicep | azurerm | azurerm | azurerm_application_insights | N/A | 2 |
| 9 | Application Insights (Func) | modules/monitor/monitoring.bicep | azurerm | azurerm | azurerm_application_insights | N/A | 2 |
| 10 | Application Insights (Foundry) | modules/monitor/monitoring.bicep | azurerm | azurerm | azurerm_application_insights | N/A | 2 |
| 11 | Dashboards | modules/monitor/monitoring.bicep | azurerm | azurerm | azurerm_portal_dashboard | N/A | 2 |
| 12 | Azure Monitor Private Link Scope | modules/monitor/monitoring.bicep | azurerm | azurerm | azurerm_monitor_private_link_scope | N/A | 2 |
| 13 | Key Vault | modules/keyvault/keyvault.bicep | AVM | azurerm | Azure/avm-res-keyvault-vault | ~> 0.9 | 2 |
| 14 | Key Vault Secret | modules/keyvault/keyvault-secret.bicep | azurerm | azurerm | azurerm_key_vault_secret | N/A | 2 |
| 15 | Key Vault RBAC | modules/keyvault/keyvault-rbac.bicep | azurerm | azurerm | azurerm_role_assignment | N/A | 2 |
| 16 | AI Foundry (Cognitive Services Account) | modules/foundry/foundry.bicep | AzAPI | azapi | azapi_resource | 2024-10-01 | 2 |
| 17 | AI Foundry Project (Hub) | modules/foundry/foundry.bicep | AzAPI | azapi | azapi_resource | 2024-10-01 | 2 |
| 18 | AI Foundry Model Deployments | modules/foundry/deployments.bicep | AzAPI | azapi | azapi_resource | 2024-10-01 | 2 |
| 19 | AI Foundry Private Endpoints | modules/foundry/foundry.bicep | azurerm | azurerm | azurerm_private_endpoint | N/A | 2 |
| 20 | Cosmos DB Account | modules/cosmos-db/cosmos-db.bicep | AVM | azurerm | Azure/avm-res-documentdb-databaseaccount | ~> 0.5 | 2 |
| 21 | Cosmos DB Database | modules/cosmos-db/cosmos-db.bicep | azurerm | azurerm | azurerm_cosmosdb_sql_database | N/A | 2 |
| 22 | Cosmos DB Containers | modules/cosmos-db/cosmos-db.bicep | azurerm | azurerm | azurerm_cosmosdb_sql_container | N/A | 2 |
| 23 | Event Hub Namespace | modules/event-hub/event-hub.bicep | AzAPI | azapi | azapi_resource | 2024-01-01 | 4 |
| 24 | Event Hub | modules/event-hub/event-hub.bicep | AzAPI | azapi | azapi_resource | 2024-01-01 | 4 |
| 25 | Event Hub Private Endpoint | modules/event-hub/event-hub.bicep | azurerm | azurerm | azurerm_private_endpoint | N/A | 4 |
| 26 | Storage Account | modules/functionapp/storageaccount.bicep | AVM | azurerm | Azure/avm-res-storage-storageaccount | ~> 0.14 | 4 |
| 27 | Storage File Share | modules/functionapp/storageaccount.bicep | azurerm | azurerm | azurerm_storage_share | N/A | 4 |
| 28 | Storage Private Endpoints | modules/functionapp/storageaccount.bicep | azurerm | azurerm | azurerm_private_endpoint | N/A | 4 |
| 29 | Logic App (Workflow Standard) | modules/logicapp/logicapp.bicep | AzAPI | azapi | azapi_resource | 2024-04-01 | 4 |
| 30 | Logic App Workflow | modules/logicapp/logicapp.bicep | azurerm | azurerm | azurerm_logic_app_workflow | N/A | 4 |
| 31 | APIM Service | modules/apim/apim.bicep | AzAPI | azapi | azapi_resource | 2024-05-01 | 3 |
| 32 | APIM APIs | modules/apim/*.bicep | AzAPI | azapi | azapi_resource | 2024-05-01 | 3 |
| 33 | APIM Backends | modules/apim/llm-backends.bicep | AzAPI | azapi | azapi_resource | 2024-05-01 | 3 |
| 34 | APIM Backend Pools | modules/apim/llm-backend-pools.bicep | AzAPI | azapi | azapi_resource | 2024-05-01 | 3 |
| 35 | APIM Policy Fragments | modules/apim/llm-policy-fragments.bicep | AzAPI | azapi | azapi_resource | 2024-05-01 | 3 |
| 36 | APIM Named Values | modules/apim/apim.bicep | AzAPI | azapi | azapi_resource | 2024-05-01 | 3 |
| 37 | APIM Loggers | modules/apim/apim.bicep | AzAPI | azapi | azapi_resource | 2024-05-01 | 3 |
| 38 | APIM Diagnostics | modules/apim/apim.bicep | AzAPI | azapi | azapi_resource | 2024-05-01 | 3 |
| 39 | APIM V2 Private Endpoint | modules/apim/apim.bicep | azurerm | azurerm | azurerm_private_endpoint | N/A | 3 |
| 40 | API Center | modules/apic/apic.bicep | AzAPI | azapi | azapi_resource | 2024-03-01 | 3 |
| 41 | API Center Workspace | modules/apic/apic.bicep | AzAPI | azapi | azapi_resource | 2024-03-01 | 3 |
| 42 | API Center APIs | modules/apim/api-center-onboarding.bicep | AzAPI | azapi | azapi_resource | 2024-03-01 | 3 |
| 43 | Managed Redis | modules/redis/redis.bicep | AVM | azurerm | Azure/avm-res-cache-redis | ~> 0.3 | 4 |
| 44 | Redis Private Endpoint | modules/redis/redis.bicep | azurerm | azurerm | azurerm_private_endpoint | N/A | 4 |

## Key AzAPI Resources (Custom Implementation Required)

### Microsoft Foundry (AI Services)
- **Type**: `Microsoft.CognitiveServices/accounts@2024-10-01`
- **Kind**: `AIServices`
- **Properties**: 
  - `customSubDomainName`
  - `networkAcls` (public/private access)
  - `publicNetworkAccess`
  - Network injection via `containerApps` property
  - Connections to Key Vault

### Microsoft Foundry Project (Hub)
- **Type**: `Microsoft.MachineLearningServices/workspaces@2024-10-01`
- **Kind**: `Hub`
- **Properties**:
  - `friendlyName`
  - `keyVault` (reference)
  - `applicationInsights` (reference)
  - `storageAccount` (reference)
  - `aiServices` (reference to Foundry account)

### Model Deployments
- **Type**: `Microsoft.CognitiveServices/accounts/deployments@2024-10-01`
- **Properties**:
  - `model.name`
  - `model.format` (OpenAI, DeepSeek, Microsoft)
  - `model.version`
  - `sku.name` (GlobalStandard, Standard)
  - `sku.capacity` (TPM quota)
  - `retirementDate` (optional metadata)

### APIM Service
- **Type**: `Microsoft.ApiManagement/service@2024-05-01`
- **Properties**:
  - `sku` (Developer, Premium, StandardV2, PremiumV2)
  - `virtualNetworkType` (External, Internal, None)
  - `virtualNetworkConfiguration` (subnet ID)
  - `publicNetworkAccess` (v2 SKUs)
  - `identity` (user-assigned)
  - `customProperties` (semantic cache configuration)

### APIM APIs
- **Type**: `Microsoft.ApiManagement/service/apis@2024-05-01`
- **Properties**:
  - `path` (API path prefix)
  - `protocols` (http, https, ws, wss)
  - `apiType` (http, soap, websocket, graphql)
  - `serviceUrl` (backend URL - NOT used with backend pools)
  - OpenAPI spec (`format: openapi+json`, `value: <spec>`)
  - Policy (inbound/backend/outbound/on-error)

### APIM Backends
- **Type**: `Microsoft.ApiManagement/service/backends@2024-05-01`
- **Properties**:
  - `url` (backend endpoint)
  - `protocol` (http, soap)
  - `credentials.authorization.scheme` (managed identity, key)
  - `properties` (model metadata: modelFormat, modelVersion, capacity, retirementDate)
  - Circuit breaker rules

### APIM Backend Pools (Multi-backend load balancing)
- **Type**: `Microsoft.ApiManagement/service/backends@2024-05-01`
- **Properties**:
  - `type: Pool`
  - `pool.services[]` (array of backend IDs)
  - Load balancing: `priority` (1-5), `weight` (1-1000)

### APIM Policy Fragments
- **Type**: `Microsoft.ApiManagement/service/policyFragments@2024-05-01`
- **Properties**:
  - `value` (XML policy content)
  - `description`
  - Used via `<include-fragment fragment-id="..." />`

### Event Hub Namespace
- **Type**: `Microsoft.EventHub/namespaces@2024-01-01`
- **Properties**:
  - `sku` (Basic, Standard, Premium)
  - `capacity` (throughput units)
  - `publicNetworkAccess`

### Event Hub
- **Type**: `Microsoft.EventHub/namespaces/eventhubs@2024-01-01`
- **Properties**:
  - `messageRetentionInDays`
  - `partitionCount`

### Logic App (Workflow Standard)
- **Type**: `Microsoft.Web/sites@2024-04-01`
- **Kind**: `functionapp,workflowapp`
- **Properties**:
  - `siteConfig` (function app settings)
  - `virtualNetworkSubnetId` (VNet integration)
  - `storageAccountRequired: true`
  - APPSETTINGS (Event Hub, Cosmos DB, App Insights connections)

### API Center
- **Type**: `Microsoft.ApiCenter/services@2024-03-01`
- **Properties**:
  - `sku` (Free, Standard)

### API Center Workspace
- **Type**: `Microsoft.ApiCenter/services/workspaces@2024-03-01`
- **Properties**:
  - `title`, `description`

### API Center API
- **Type**: `Microsoft.ApiCenter/services/workspaces/apis@2024-03-01`
- **Properties**:
  - `title`, `kind`, `externalDocumentation`
  - `lifecycleStage` (design, development, testing, production, deprecated)

## Bicep Features That Don't Port Cleanly

### 1. Conditional Modules with Array Iteration
**Bicep**: `module dnsDeployment './modules/networking/dns.bicep' = [for privateDnsZoneName in privateDnsZoneNames: if(!useExistingVnet) { ... }]`  
**TF**: Use `for_each` with conditional map (`var.use_existing_vnet ? {} : { for name in var.dns_zones : name => name }`)

### 2. Dynamic Backend Configuration Generation
**Bicep**: Complex array transformations with `filter()`, `map()`, `union()` to build `llmBackendConfig` from `aiFoundryInstances` + `aiFoundryModelsConfig`  
**TF**: Use `locals` with nested `for` expressions and `flatten()` to achieve similar logic

### 3. Entra ID App Registration & Secret Management
**Bicep**: Relies on external PowerShell script (`entra-id-setup/setup.ps1`) to provision app registration, then stores secret in Key Vault  
**TF**: Document as PREREQUISITE — users must create app registration + store secret in KV before running module (or provide existing secret reference)

### 4. API Center Onboarding (OpenAPI Spec Sync)
**Bicep**: Reads APIM APIs and publishes to API Center with complex dependencies  
**TF**: Implement as post-deployment optional step (or separate module) — NOT in core hub module

### 5. Usage Logic App Workflow Definition
**Bicep**: Deploys `src/usage-ingestion-logicapp/` app code as part of Logic App site deployment  
**TF**: Deploy Logic App site, reference external workflow definition JSON (user provides app code separately or via ZIP deploy)

### 6. Policy/OpenAPI JSON Files
**Bicep**: Loads JSON files via `loadJsonContent()` or `loadTextContent()`  
**TF**: Bundle JSON files in module under `files/` directory, load via `file()` or `templatefile()` functions

## AVM Module Versions (Pinned)

| Resource | AVM Module | Version |
|----------|-----------|---------|
| Virtual Network | Azure/avm-res-network-virtualnetwork | ~> 0.7.0 |
| Log Analytics | Azure/avm-res-operationalinsights-workspace | ~> 0.4.0 |
| Key Vault | Azure/avm-res-keyvault-vault | ~> 0.9.0 |
| Cosmos DB | Azure/avm-res-documentdb-databaseaccount | ~> 0.5.0 |
| Storage Account | Azure/avm-res-storage-storageaccount | ~> 0.14.0 |
| Managed Redis | Azure/avm-res-cache-redis | ~> 0.3.0 |

## Module Structure

```
terraform-azurerm-avm-ptn-aifoundry-citadel-gateway/
├── terraform.tf         # Provider versions
├── variables.tf         # All input variables
├── main.tf              # Root module orchestration
├── locals.tf            # Local computations (backend config, DNS zones, etc.)
├── outputs.tf           # Module outputs
├── LICENSE              # MIT License
├── README.md            # Module documentation
├── .gitignore           # Git ignore patterns
├── RESOURCE_INVENTORY.md # This file
├── examples/
│   └── default/         # Example deployment
│       ├── main.tf
│       ├── variables.tf
│       └── README.md
└── modules/
    ├── networking/      # VNet, subnets, NSGs, DNS zones
    ├── identities/      # Managed identities
    ├── monitoring/      # Log Analytics, App Insights, dashboards
    ├── foundry/         # AI Foundry resources (azapi)
    ├── apim/            # APIM service + gateway config (azapi)
    ├── apic/            # API Center (azapi)
    ├── event-hub/       # Event Hub namespace + hubs (azapi)
    ├── logic-app/       # Logic App (azapi)
    └── usage-ingestion/ # Storage, Cosmos, usage pipeline
```

## Notes

- **Phase 1**: Skeleton + inventory (this document) ✅
- **Phase 2**: Networking, identities, monitoring, Key Vault, Foundry, Cosmos
- **Phase 3**: APIM + AI Gateway (backends, pools, fragments, APIs, policies)
- **Phase 4**: Event Hub, Storage, Logic App, Redis (opt-in)

**Status**: Phase 1 in progress — creating skeleton files next.
