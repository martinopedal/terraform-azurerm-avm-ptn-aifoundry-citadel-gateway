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

# Networking
module "networking" {
  source = "./modules/networking"

  create_new_vnet                      = !var.use_existing_vnet
  vnet_name                            = var.vnet_name != "" ? var.vnet_name : "vnet-${local.resource_token}"
  vnet_address_prefix                  = var.vnet_address_prefix
  location                             = var.location
  resource_group_name                  = azurerm_resource_group.this.name
  existing_vnet_resource_group_name    = var.existing_vnet_rg
  tags                                 = local.tags
  
  apim_subnet_name             = var.apim_subnet_name != "" ? var.apim_subnet_name : "snet-apim"
  apim_subnet_prefix           = var.apim_subnet_prefix
  private_endpoint_subnet_name = var.private_endpoint_subnet_name != "" ? var.private_endpoint_subnet_name : "snet-private-endpoint"
  private_endpoint_subnet_prefix = var.private_endpoint_subnet_prefix
  function_app_subnet_name     = var.function_app_subnet_name != "" ? var.function_app_subnet_name : "snet-functionapp"
  function_app_subnet_prefix   = var.function_app_subnet_prefix
  enable_agent_subnet          = var.foundry_network_injection_enabled
  agent_subnet_name            = var.agent_subnet_name != "" ? var.agent_subnet_name : "snet-agents"
  agent_subnet_prefix          = var.agent_subnet_prefix
  
  apim_nsg_name               = "nsg-apim-${local.resource_token}"
  private_endpoint_nsg_name   = "nsg-pe-${local.resource_token}"
  function_app_nsg_name       = "nsg-functionapp-${local.resource_token}"
  agent_subnet_nsg_name       = "nsg-agents-${local.resource_token}"
  apim_route_table_name       = "rt-apim-${local.resource_token}"
  
  is_apim_v2_sku         = local.is_apim_v2_sku
  private_dns_zone_names = local.private_dns_zones
  enable_telemetry       = var.enable_telemetry
}

# Identities
module "identities" {
  source = "./modules/identities"

  apim_identity_name    = var.apim_identity_name != "" ? var.apim_identity_name : "id-apim-${local.resource_token}"
  usage_identity_name   = var.usage_logic_app_identity_name != "" ? var.usage_logic_app_identity_name : "id-logicapp-${local.resource_token}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  resource_group_id     = azurerm_resource_group.this.id
  tags                  = local.tags
}

# Monitoring
module "monitoring" {
  source = "./modules/monitoring"

  log_analytics_name              = var.log_analytics_name != "" ? var.log_analytics_name : "law-${local.resource_token}"
  use_existing_log_analytics      = var.use_existing_log_analytics
  existing_log_analytics_name     = var.existing_log_analytics_name
  existing_log_analytics_rg       = var.existing_log_analytics_rg
  log_analytics_retention_days    = var.log_analytics_retention_days
  
  apim_app_insights_name     = "appi-apim-${local.resource_token}"
  function_app_insights_name = "appi-func-${local.resource_token}"
  foundry_app_insights_name  = "appi-foundry-${local.resource_token}"
  
  apim_dashboard_name     = "dash-apim-${local.resource_token}"
  function_dashboard_name = "dash-func-${local.resource_token}"
  foundry_dashboard_name  = "dash-foundry-${local.resource_token}"
  
  create_dashboards                    = var.create_app_insights_dashboards
  use_azure_monitor_private_link_scope = var.use_azure_monitor_private_link_scope
  enable_private_endpoints             = var.enable_private_endpoints
  private_endpoint_subnet_id           = module.networking.private_endpoint_subnet_id
  monitor_private_dns_zone_id          = var.existing_private_dns_zones.monitor
  
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
}

# Key Vault
module "key_vault" {
  source = "./modules/key-vault"

  key_vault_name                          = var.key_vault_name != "" ? var.key_vault_name : "kv-${local.resource_token}"
  key_vault_sku_name                      = var.key_vault_sku_name
  key_vault_public_network_access_enabled = var.key_vault_external_network_access == "Enabled"
  key_vault_private_endpoint_name         = "pe-kv-${local.resource_token}"
  key_vault_private_dns_zone_id           = var.existing_private_dns_zones.key_vault
  enable_private_endpoints                = var.enable_private_endpoints
  private_endpoint_subnet_id              = module.networking.private_endpoint_subnet_id
  apim_principal_id                       = module.identities.apim_identity_principal_id
  entra_client_secret                     = var.entra_client_secret
  
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
}

# AI Foundry
module "foundry" {
  source = "./modules/foundry"

  foundry_instances                       = var.ai_foundry_instances
  foundry_public_network_access_enabled   = var.ai_foundry_external_network_access == "Enabled"
  disable_local_auth                      = var.disable_local_auth
  foundry_private_dns_zone_ids            = compact([
    var.existing_private_dns_zones.cognitive_services,
    var.existing_private_dns_zones.openai,
    var.existing_private_dns_zones.ai_services
  ])
  enable_private_endpoints  = var.enable_private_endpoints
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  apim_principal_id         = module.identities.apim_identity_principal_id
  resource_token            = local.resource_token
  
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id
  tags                = local.tags
}

# Cosmos DB
module "cosmos" {
  source = "./modules/cosmos"

  cosmos_account_name                     = var.cosmos_db_account_name != "" ? var.cosmos_db_account_name : "cosmos-${local.resource_token}"
  cosmos_capacity_mode                    = var.cosmos_capacity_mode
  cosmos_public_network_access_enabled    = var.cosmos_db_public_access == "Enabled"
  database_name                           = "ai-usage-db"
  container_name_usage                    = "ai-usage-container"
  container_name_pii                      = "pii-usage-container"
  container_name_llm                      = "llm-usage-container"
  throughput                              = var.cosmos_db_rus
  cosmos_private_endpoint_name            = "pe-cosmos-${local.resource_token}"
  cosmos_private_dns_zone_id              = var.existing_private_dns_zones.cosmos_db
  enable_private_endpoints                = var.enable_private_endpoints
  private_endpoint_subnet_id              = module.networking.private_endpoint_subnet_id
  
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
}

# ============================================================================
# PHASE 3: AI Gateway (APIM + Gateway Core + API Center)
# ============================================================================

# Placeholder: Modules will be added in Phase 3

# ============================================================================
# PHASE 4: Usage Ingestion + Redis
# ============================================================================

# Placeholder: Modules will be added in Phase 4
