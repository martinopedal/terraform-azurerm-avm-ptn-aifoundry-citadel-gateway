## Phase 1: Inventory and Skeleton

Terraform port of the Bicep accelerator **Azure-Samples/ai-hub-gateway-solution-accelerator @ branch citadel-v1** (Citadel Governance Hub — Layer 1 of the Foundry Citadel Platform).

### Completed
- ✅ Comprehensive resource inventory (RESOURCE_INVENTORY.md) mapping 44 Bicep resources to Terraform
- ✅ Scaffolded module structure (terraform.tf, variables.tf, locals.tf, main.tf, outputs.tf, README.md, LICENSE, .gitignore)
- ✅ All input variables defined (90+ variables matching Bicep parameter surface)
- ✅ Module directories created (networking, identities, monitoring, foundry, apim, apic, event-hub, logic-app, usage-ingestion)
- ✅ Validated: terraform fmt + terraform init + terraform validate — all PASS

### Resource Mapping
| Category | Count | Approach |
|----------|-------|----------|
| AzAPI resources | 18 | APIM, Foundry, API Center, Event Hub, Logic App |
| AVM modules | 6 | VNet, Log Analytics, Key Vault, Cosmos DB, Storage, Redis |
| azurerm resources | 20 | Managed identities, App Insights, dashboards, role assignments, PE, secrets |

### Key Decisions
1. **Managed Redis is OPT-IN** (`enable_managed_redis = false` by default)
2. **AzAPI-first** for APIM, Foundry, API Center, Event Hub, Logic App (tracks ARM API surface)
3. **AVM modules pinned** to explicit semver (e.g., VNet ~> 0.7.0, Key Vault ~> 0.9.0)
4. **No secrets in code** — all secrets parameterized
5. **BYO VNet support** via `use_existing_vnet = true` + `existing_private_dns_zones` object

### Next Phase
**Phase 2: Core Hub** — networking, identities, monitoring, Key Vault, Foundry, Cosmos DB

### Review Request
@martinopedal — please review the inventory and skeleton structure. Once approved, I'll proceed with Phase 2 implementation.

**Note**: This PR is ready for multi-model code review. The module is PRIVATE and will remain so until successful end-to-end deployment in our tenant.
