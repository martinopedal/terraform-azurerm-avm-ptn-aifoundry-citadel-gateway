# ============================================================================
# CITADEL GOVERNANCE HUB - MAIN MODULE ORCHESTRATION
# ============================================================================
# Terraform port of Azure-Samples/ai-hub-gateway-solution-accelerator @ citadel-v1
# This module deploys Layer 1 of the Foundry Citadel Platform:
#   - Networking (VNet or BYO)
#   - Managed Identities
#   - Monitoring (Log Analytics, App Insights, Dashboards, AMPLS)
#   - Key Vault
#   - AI Foundry (Cognitive Services + Hub + Deployments)
#   - Cosmos DB
#   - APIM AI Gateway (APIs, backends, pools, policy fragments)
#   - API Center
#   - Usage Ingestion Pipeline (Event Hub, Storage, Logic App)
#   - Managed Redis (opt-in, default: false)

# ============================================================================
# RESOURCE GROUP
# ============================================================================

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

# ============================================================================
# PHASE 2: Core Hub (Networking, Identities, Monitoring, Key Vault, Foundry, Cosmos)
# ============================================================================

# Placeholder: Modules will be added in Phase 2

# ============================================================================
# PHASE 3: AI Gateway (APIM + Gateway Core + API Center)
# ============================================================================

# Placeholder: Modules will be added in Phase 3

# ============================================================================
# PHASE 4: Usage Ingestion + Redis
# ============================================================================

# Placeholder: Modules will be added in Phase 4
