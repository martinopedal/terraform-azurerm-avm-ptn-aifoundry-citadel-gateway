# Security & Reliability Toggles Summary

**Directive**: Add clean security + reliability toggles, cheap/permissive defaults, opt-in to harden.

## Variables Added (7 New)

### Security Toggles (3)

| Variable | Default | Cost Impact | Production Flip |
|----------|---------|-------------|-----------------|
| `enable_private_endpoints` | `true` | +$70/mo (10 PEs x $7.30) | Keep TRUE |
| `disable_local_auth` | `false` | Free | TRUE (AAD-only, zero-trust) |
| `enable_customer_managed_keys` | `false` | ~$0.03/10k KV ops (minimal) | TRUE (CMEK for compliance) |

### Reliability Toggles (4)

| Variable | Default | Cost Impact | SKU Coupling |
|----------|---------|-------------|--------------|
| `enable_zone_redundancy` | `false` | +$650-2750/mo | Requires APIM StandardV2/Premium, Event Hub Premium, Storage ZRS |
| `log_analytics_retention_days` | `30` | 31-365 days = +$0.12/GB/month | None |
| `cosmos_backup_type` | `Periodic` (7-day) | Continuous (30-day) requires provisioned mode | Couples to `cosmos_capacity_mode = provisioned` |
| `storage_soft_delete_days` | `7` | Free (1-365 days) | None |

## SKU Coupling (Critical for Zone Redundancy)

**When `enable_zone_redundancy = true`, you MUST also:**
1. Set `apim_sku = "StandardV2"` or `"PremiumV2"` (Developer doesn't support zones) → +$650-2750/mo
2. Set `event_hub_sku = "Premium"` (Standard doesn't support zones) → +$625/mo
3. Storage automatically uses ZRS (no manual config) → +$0.002/GB (minimal)
4. Cosmos requires multi-region config (not covered by simple toggle, manual setup) → pay per additional region

**If you enable zone redundancy without upgrading SKUs, deployment WILL FAIL.** Module will validate and error with guidance.

## Cost Summary

**Demo Baseline** (cheap defaults):
- `enable_private_endpoints = true` (~$70/mo, ALZ default)
- `disable_local_auth = false` (allow keys for simplicity)
- `enable_customer_managed_keys = false`
- `enable_zone_redundancy = false`
- `log_analytics_retention_days = 30` (free)
- `cosmos_backup_type = "Periodic"` (7-day, included)
- `storage_soft_delete_days = 7` (free)

**Total Demo Cost**: ~$360/mo (unchanged from cost directive baseline)

**Production Hardening** (all toggles ON + SKU bumps):
- `disable_local_auth = true` (FREE)
- `enable_customer_managed_keys = true` (~$0.03/10k ops, minimal)
- `enable_zone_redundancy = true` + `apim_sku = "StandardV2"` + `event_hub_sku = "Premium"` (+$1275/mo)
- `log_analytics_retention_days = 90` (+$0.12/GB/month for 31-90 days, volume-dependent, ~$5-20/mo)
- `cosmos_backup_type = "Continuous"` (requires provisioned mode, couples to capacity mode)
- `storage_soft_delete_days = 30` (FREE)

**Total Production Cost** (hardened): ~$1.6k-3k/mo (depending on APIM tier: StandardV2 vs Premium)

## Variable Surface Complexity

**Added 7 variables**, grouped into 2 clean categories:
- Security (3 vars): PE, auth, CMEK
- Reliability (4 vars): zones, retention/backup configs

**Did NOT explode the surface** — no dozens of micro-knobs. Each variable is well-named, documented with `# cost:` comment, and added to COST_RUNBOOK.md.

## Documentation Updates

1. **variables.tf**: Added 7 vars with `# cost:` comments in 2 grouped sections
2. **COST_RUNBOOK.md**: Added Security & Reliability Toggles section with tables, SKU coupling note, production override example
3. **README.md**: Updated Key Variables table, added SKU coupling note, updated cost summary

## Validation

```bash
terraform fmt      # ✅ PASS
terraform validate # ✅ PASS
```

## Next Steps

These variables are now **ready to be wired** into Phase 2-4 implementation:
- **Phase 2**: Wire `enable_private_endpoints`, `disable_local_auth` into Key Vault, Foundry, Cosmos
- **Phase 3**: Wire `enable_zone_redundancy` into APIM, `enable_customer_managed_keys` into APIM cache
- **Phase 4**: Wire `enable_zone_redundancy` into Event Hub, Storage; `cosmos_backup_type` into Cosmos config

**Carry on with Phase 2 Core Hub** — fold these vars in as each resource is implemented.
