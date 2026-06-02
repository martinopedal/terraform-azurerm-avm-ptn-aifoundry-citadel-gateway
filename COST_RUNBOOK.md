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

## Cost Optimization Opportunities (Post-Demo)

1. **Logic App**: Switch WS1 → Consumption if no VNet integration needed = -$200/mo
2. **APIM**: Keep Developer for non-prod environments; only upgrade to StandardV2/Premium for production SLA
3. **Redis**: Keep OFF unless semantic cache hit rate justifies $200/mo cost
4. **Model capacity**: Start with 1k TPM, scale up only if rate-limited
5. **Cosmos DB**: Monitor RU consumption; if >1M RU/day sustained, switch to provisioned autoscale for cost savings

## Phase-by-Phase Cost Tracking

- **Phase 2** (Core Hub): ~$130/mo (APIM $50 + Log Analytics $10 + Key Vault $0.50 + VNet PE ~$70)
- **Phase 3** (AI Gateway + Foundry): +$0 (Foundry pay-per-use, no base cost)
- **Phase 4** (Usage Ingestion): +$230/mo (Event Hub $25 + Logic App $200 + Storage $0.50 + Cosmos $5)
- **Phase 4** (Redis OPT-IN): +$200/mo (if enabled)

**Total demo cost**: ~$360/mo (Redis OFF)

## Variable Overrides for Production

```hcl
# Production overrides (example)
apim_sku                   = "StandardV2"      # +$650/mo
cosmos_capacity_mode       = "provisioned"     # +$24/mo (400 RUs)
event_hub_capacity_units   = 2                 # +$25/mo
logic_apps_sku             = "WS2"             # +$200/mo (more compute)
enable_managed_redis       = true              # +$200/mo
redis_sku_name             = "Balanced_B10"    # +$1800/mo vs B1
ai_foundry_models_config = [
  {
    name     = "gpt-4o"
    capacity = 100000  # 100k TPM for prod volume
    # ...
  }
]
```

---

**Last Updated**: Phase 1 (2025-01-XX)  
**Status**: Demo defaults applied. Production overrides documented.  
**Next**: Validate SKU choices during Phase 2-4 implementation against live Azure pricing.
