# Cost Runbook — Citadel Gateway Demo Defaults

**Objective**: Deploy the Citadel Governance Hub at MINIMUM viable cost for demo/testing.

## Monthly Cost Estimate (Demo Defaults)

| Resource | SKU/Tier | Quantity | Est. Monthly Cost | Notes |
|----------|----------|----------|-------------------|-------|
| **APIM** | Developer | 1 instance | ~$50 | VNet-capable, no SLA. Production: StandardV2 (~$700) or Premium (~$2.8k) |
| **Log Analytics** | PerGB2018 | 30-day retention | ~$2-10 | Pay-as-you-go, depends on ingestion volume |
| **App Insights** (3x) | Pay-per-GB | - | ~$5-15 | APIM, Function, Foundry telemetry |
| **Key Vault** | Standard | 10k ops | ~$0.50 | Secrets for Entra client secret, Redis conn string |
| **Foundry (AI Services)** | S0 | 1 account | ~$0 | Pay-per-token, no base cost |
| **Model Deployment** | Standard | gpt-4o-mini, 1k TPM | ~$0 | Pay-per-use: $0.15/1M input, $0.60/1M output |
| **Cosmos DB** | Serverless | NoSQL API | ~$0-5 | Pay-per-RU consumed, no base cost. Low volume = low cost. |
| **Event Hub** | Standard | 1 TU | ~$25 | 7-day retention, no capture, no auto-inflate |
| **Storage Account** | Standard LRS | <1 GB | ~$0.50 | Function App content share + Logic App content |
| **Logic App** | WorkflowStandard (WS1) | 1 instance | ~$200 | VNet integration. **RESEARCH**: Can we use Consumption (~$0)? |
| **VNet + Subnets** | - | 4 subnets | ~$0 | VNet is free, PE ~$7/mo each (x10 = ~$70) |
| **Private Endpoints** | - | ~10 PE | ~$70 | $7.30/mo per PE |
| **Managed Redis** | *(OPT-IN, default OFF)* | Balanced_B1, 1 GB | ~$200 | When enabled. Semantic cache for APIM. |

**TOTAL (Demo, Redis OFF)**: ~$360/mo  
**TOTAL (Demo, Redis ON)**: ~$560/mo

**Production delta** (if deploying for real workload):
- APIM: Developer → StandardV2 = +$650/mo
- Cosmos DB: Serverless → Provisioned 400 RUs = +$24/mo
- Logic App: **IF** we can use Consumption, WS1 → Consumption = -$200/mo
- Foundry: Pay-per-token scales with usage (demo = low, prod = high)

## SKU Decisions & Rationale

### API Management (APIM)
**Default**: `Developer` (~$50/mo)  
**Why**: Supports VNet injection (External/Internal), AI gateway policies, loggers, diagnostics. Single instance, no SLA.  
**Production**: `StandardV2` (~$700/mo, multi-instance, 99.95% SLA, zone redundancy) or `Premium` (~$2.8k/mo, multi-region, VPN, cache).  
**Research**: Confirmed Developer supports all gateway features needed (policy fragments, backends, backend pools, managed identity auth, Event Hub logger).

### Cosmos DB
**Default**: `serverless` (~$0 base, pay-per-RU)  
**Why**: Usage analytics is write-heavy, low query volume. Serverless is cost-optimal for <1M RU/day. 5k RU/s burst limit is sufficient.  
**Production**: `provisioned` with autoscale (400-4000 RUs) if predictable workload.  
**Research**: Serverless supports SQL API, change feed (for Logic App), private endpoints.

### Event Hub
**Default**: `Standard` (~$25/mo base + $0.028/million events)  
**Why**: 7-day retention (vs Basic 1-day), supports capture (if needed later). 1 TU = 1 MB/s ingress, sufficient for demo.  
**Production**: Same, or Premium (~$650/mo) for Kafka, dedicated compute.  
**Research**: Confirmed APIM logger supports both Basic and Standard. Auto-inflate OFF to prevent cost overrun.

### Logic App (Usage Ingestion)
**Default**: `WorkflowStandard (WS1)` (~$200/mo)  
**Why**: Bicep accelerator uses this. Supports VNet integration, private endpoints, stateful workflows.  
**RESEARCH NEEDED (Phase 4)**: Can the usage ingestion workflow run on **Consumption** (~$0.000025/action)? If yes, change default to Consumption and save $200/mo.  
**Trade-off**: Consumption has no VNet integration, but if Event Hub is publicly accessible during provisioning, Consumption may work.

### Foundry (AI Services) + Model Deployments
**Default**: `S0` tier (pay-per-token, no base cost) + `Standard` deployment (not Provisioned/PTU) + `gpt-4o-mini` (cheapest model) + `1k TPM` capacity  
**Why**: Demo usage is low-volume. Standard = $0.15/1M input, $0.60/1M output. 1k TPM = max 1000 tokens/min.  
**Production**: Increase capacity (10k-100k TPM), use gpt-4o/gpt-4.1 for better quality, or Provisioned Throughput Units (PTU) for cost control at high volume.  
**Research**: Confirmed Standard supports managed identity backend auth, global load balancing (GlobalStandard).

### Log Analytics
**Default**: `PerGB2018` (pay-per-GB, $2.30/GB ingested) + `30-day` retention  
**Why**: Demo ingestion is low (<1 GB/day). 30-day retention is free; 31-365 days = $0.12/GB/month.  
**Production**: Increase retention or use Commitment Tiers (100 GB/day = $1.83/GB).  
**Research**: Confirmed supports App Insights integration, diagnostic logs from all resources.

### Managed Redis (OPT-IN, default OFF)
**Default**: `Balanced_B1` (~$200/mo, 1 GB cache, 1k ops/s)  
**Why**: Semantic cache for APIM. B1 is cheapest tier. For demo, **default is OFF** (`enable_managed_redis = false`).  
**Production**: Balanced_B10 (~$2k/mo, 10 GB) or MemoryOptimized_M10 (~$2k/mo) for higher cache hit rate.  
**Research**: Confirmed B1 supports private endpoints, managed identity (via connection string in Key Vault).

### Key Vault
**Default**: `standard` (~$0.03/10k ops)  
**Why**: Stores Entra client secret, Redis connection string. Standard is sufficient; Premium adds HSM.  
**Production**: Same, or Premium if HSM-backed keys required.

### VNet + Private Endpoints
**Default**: VNet is **free**. Private endpoints = $7.30/mo each.  
**Count**: ~10 PE (Foundry x3 DNS zones = 1 PE, Key Vault, Cosmos, Event Hub, Storage x4 subresources, APIM v2, Redis).  
**Total PE cost**: ~$70/mo  
**Research**: Confirmed all resources support private endpoints.

## Security & Reliability Toggles (Added 2025-01-XX)

Martin's directive: add clean security + reliability toggles, cheap/permissive defaults, opt-in to harden.

### Security Toggles

| Variable | Default | Cost Impact | Production Flip |
|----------|---------|-------------|-----------------|
| `enable_private_endpoints` | `true` | +$70/mo (10 PEs x $7.30) | Keep TRUE |
| `disable_local_auth` | `false` | Free | TRUE (AAD-only) |
| `enable_customer_managed_keys` | `false` | ~$0.03/10k KV ops (minimal) | TRUE (CMEK for compliance) |

**Notes**:
- **Private endpoints**: Default TRUE per ALZ private-by-default posture. Set FALSE to save ~$70/mo if public access acceptable for non-prod.
- **Disable local auth**: Requires AAD tokens for Cosmos/Storage/Event Hub/KV. Default FALSE (allow keys) for demo simplicity. Production: TRUE for zero-trust.
- **Customer-managed keys (CMEK)**: Encrypt data with KV-managed keys. Default FALSE for demo simplicity. Production: TRUE for compliance (e.g., HIPAA, FedRAMP).

### Reliability Toggles

| Variable | Default | Cost Impact | SKU Coupling |
|----------|---------|-------------|--------------|
| `enable_zone_redundancy` | `false` | +$650-2750/mo (SKU bumps) | Requires APIM StandardV2/Premium, Event Hub Premium, Storage ZRS, Cosmos multi-region |
| `log_analytics_retention_days` | `30` | 31-365 days = +$0.12/GB/month | N/A |
| `cosmos_backup_type` | `Periodic` (7-day) | Continuous (30-day) requires provisioned mode | Couples to `cosmos_capacity_mode = provisioned` |
| `storage_soft_delete_days` | `7` | Free (1-365 days) | N/A |

**Notes**:
- **Zone redundancy**: Default FALSE (single-instance, no AZ). Production: TRUE + bump SKUs:
  - APIM Developer → StandardV2 = +$650/mo
  - Event Hub Standard → Premium = +$625/mo
  - Storage LRS → ZRS = +$0.002/GB (minimal)
  - Cosmos single-region → multi-region = pay per additional region
- **Cosmos backup**: Periodic (7-day) included with serverless. Continuous (30-day) requires provisioned mode + additional cost.
- **Storage soft delete**: Free for 1-365 days. Default 7 days for demo, extend to 30-90 days for production data retention compliance.

## Cost Optimization Opportunities (Post-Demo)

1. **Logic App**: Switch WS1 → Consumption if no VNet integration needed = -$200/mo
2. **APIM**: Keep Developer for non-prod environments; only upgrade to StandardV2/Premium for production SLA + zone redundancy
3. **Redis**: Keep OFF unless semantic cache hit rate justifies $200/mo cost
4. **Model capacity**: Start with 1k TPM, scale up only if rate-limited
5. **Cosmos DB**: Monitor RU consumption; if >1M RU/day sustained, switch to provisioned autoscale for cost savings
6. **Private endpoints**: Disable for non-prod if public access acceptable = -$70/mo
7. **Zone redundancy**: Only enable for production workloads requiring 99.99% SLA (adds +$650-2750/mo in SKU upgrades)

## Phase-by-Phase Cost Tracking

- **Phase 2** (Core Hub): ~$130/mo (APIM $50 + Log Analytics $10 + Key Vault $0.50 + VNet PE ~$70)
- **Phase 3** (AI Gateway + Foundry): +$0 (Foundry pay-per-use, no base cost)
- **Phase 4** (Usage Ingestion): +$230/mo (Event Hub $25 + Logic App $200 + Storage $0.50 + Cosmos $5)
- **Phase 4** (Redis OPT-IN): +$200/mo (if enabled)

**Total demo cost**: ~$360/mo (Redis OFF)

## Variable Overrides for Production

```hcl
# Production overrides (example)
# Cost (SKU bumps)
apim_sku                   = "StandardV2"      # +$650/mo
cosmos_capacity_mode       = "provisioned"     # +$24/mo (400 RUs)
event_hub_capacity_units   = 2                 # +$25/mo
logic_apps_sku             = "WS2"             # +$200/mo (more compute)
enable_managed_redis       = true              # +$200/mo
redis_sku_name             = "Balanced_B10"    # +$1800/mo vs B1

# Security (hardening, minimal cost)
enable_private_endpoints          = true       # Already default, ~$70/mo
disable_local_auth                = true       # FREE, requires AAD-only
enable_customer_managed_keys      = true       # ~$0.03/10k KV ops (minimal)

# Reliability (requires SKU bumps)
enable_zone_redundancy            = true       # +$650-2750/mo (SKU bumps needed)
log_analytics_retention_days      = 90         # +$0.12/GB/month for 31-90 days
cosmos_backup_type                = "Continuous" # Requires provisioned mode
storage_soft_delete_days          = 30         # FREE

# Model config for production volume
ai_foundry_models_config = [
  {
    name     = "gpt-4o"
    capacity = 100000  # 100k TPM for prod volume
    # ...
  }
]
```

**Note on Zone Redundancy + SKU Coupling**:
When `enable_zone_redundancy = true`, you **MUST** also upgrade SKUs:
- APIM: `apim_sku = "StandardV2"` or `"PremiumV2"` (Developer doesn't support zones)
- Event Hub: `event_hub_sku = "Premium"` (Standard doesn't support zones)
- Storage: Automatically uses ZRS when zone redundancy enabled (LRS → ZRS, minimal cost delta)
- Cosmos: Requires multi-region configuration (not covered by this simple toggle; manual config needed)

**If you enable zone redundancy without upgrading SKUs, deployment will fail.** The module will validate and error with guidance.

---

**Last Updated**: Phase 1 (2025-01-XX)  
**Status**: Demo defaults applied. Production overrides documented.  
**Next**: Validate SKU choices during Phase 2-4 implementation against live Azure pricing.
