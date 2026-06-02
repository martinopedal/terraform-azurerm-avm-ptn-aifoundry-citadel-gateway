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

  create_new_vnet                   = !var.use_existing_vnet
  vnet_name                         = var.vnet_name != "" ? var.vnet_name : "vnet-${local.resource_token}"
  vnet_address_prefix               = var.vnet_address_prefix
  location                          = var.location
  resource_group_name               = azurerm_resource_group.this.name
  existing_vnet_resource_group_name = var.existing_vnet_rg
  tags                              = local.tags

  apim_subnet_name               = var.apim_subnet_name != "" ? var.apim_subnet_name : "snet-apim"
  apim_subnet_prefix             = var.apim_subnet_prefix
  private_endpoint_subnet_name   = var.private_endpoint_subnet_name != "" ? var.private_endpoint_subnet_name : "snet-private-endpoint"
  private_endpoint_subnet_prefix = var.private_endpoint_subnet_prefix
  function_app_subnet_name       = var.function_app_subnet_name != "" ? var.function_app_subnet_name : "snet-functionapp"
  function_app_subnet_prefix     = var.function_app_subnet_prefix
  enable_agent_subnet            = var.foundry_network_injection_enabled
  agent_subnet_name              = var.agent_subnet_name != "" ? var.agent_subnet_name : "snet-agents"
  agent_subnet_prefix            = var.agent_subnet_prefix

  apim_nsg_name             = "nsg-apim-${local.resource_token}"
  private_endpoint_nsg_name = "nsg-pe-${local.resource_token}"
  function_app_nsg_name     = "nsg-functionapp-${local.resource_token}"
  agent_subnet_nsg_name     = "nsg-agents-${local.resource_token}"
  apim_route_table_name     = "rt-apim-${local.resource_token}"

  is_apim_v2_sku         = local.is_apim_v2_sku
  private_dns_zone_names = local.private_dns_zones
  enable_telemetry       = var.enable_telemetry
}

# Identities
module "identities" {
  source = "./modules/identities"

  apim_identity_name  = var.apim_identity_name != "" ? var.apim_identity_name : "id-apim-${local.resource_token}"
  usage_identity_name = var.usage_logic_app_identity_name != "" ? var.usage_logic_app_identity_name : "id-logicapp-${local.resource_token}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id
  tags                = local.tags
}

# Monitoring
module "monitoring" {
  source = "./modules/monitoring"

  log_analytics_name           = var.log_analytics_name != "" ? var.log_analytics_name : "law-${local.resource_token}"
  use_existing_log_analytics   = var.use_existing_log_analytics
  existing_log_analytics_name  = var.existing_log_analytics_name
  existing_log_analytics_rg    = var.existing_log_analytics_rg
  log_analytics_retention_days = var.log_analytics_retention_days

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

  foundry_instances                     = var.ai_foundry_instances
  model_deployments                     = var.ai_foundry_models_config
  foundry_public_network_access_enabled = var.ai_foundry_external_network_access == "Enabled"
  disable_local_auth                    = var.disable_local_auth
  foundry_private_dns_zone_ids = compact([
    var.existing_private_dns_zones.cognitive_services,
    var.existing_private_dns_zones.openai,
    var.existing_private_dns_zones.ai_services
  ])
  enable_private_endpoints   = var.enable_private_endpoints
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  apim_principal_id          = module.identities.apim_identity_principal_id
  resource_token             = local.resource_token

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id
  tags                = local.tags
}

# Cosmos DB
module "cosmos" {
  source = "./modules/cosmos"

  cosmos_account_name                  = var.cosmos_db_account_name != "" ? var.cosmos_db_account_name : "cosmos-${local.resource_token}"
  cosmos_capacity_mode                 = var.cosmos_capacity_mode
  cosmos_public_network_access_enabled = var.cosmos_db_public_access == "Enabled"
  database_name                        = "ai-usage-db"
  container_name_usage                 = "ai-usage-container"
  container_name_pii                   = "pii-usage-container"
  container_name_llm                   = "llm-usage-container"
  throughput                           = var.cosmos_db_rus
  cosmos_private_endpoint_name         = "pe-cosmos-${local.resource_token}"
  cosmos_private_dns_zone_id           = var.existing_private_dns_zones.cosmos_db
  enable_private_endpoints             = var.enable_private_endpoints
  private_endpoint_subnet_id           = module.networking.private_endpoint_subnet_id

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
}

# ============================================================================
# PHASE 3: AI Gateway (APIM + Gateway Core + API Center)
# ============================================================================

# Storage Account
module "storage" {
  source = "./modules/storage"

  storage_account_name             = var.storage_account_name != "" ? var.storage_account_name : "st${replace(local.resource_token, "-", "")}"
  account_replication_type         = var.storage_account_replication_type
  public_network_access_enabled    = var.storage_account_public_access == "Enabled"
  enable_private_endpoints         = var.enable_private_endpoints
  private_endpoint_subnet_id       = module.networking.private_endpoint_subnet_id
  storage_blob_private_dns_zone_id = var.existing_private_dns_zones.storage_blob
  storage_file_private_dns_zone_id = var.existing_private_dns_zones.storage_file

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

# Function App
module "function" {
  source = "./modules/function"

  function_app_name              = var.function_app_name != "" ? var.function_app_name : "func-${local.resource_token}"
  service_plan_name              = "plan-func-${local.resource_token}"
  storage_account_name           = module.storage.storage_account_name
  storage_account_access_key     = module.storage.primary_access_key
  vnet_integration_enabled       = var.function_vnet_integration_enabled
  function_subnet_id             = module.networking.function_app_subnet_id
  app_insights_connection_string = module.monitoring.function_app_insights_connection_string
  app_insights_key               = module.monitoring.function_app_insights_instrumentation_key

  app_settings = {
    "AI_FOUNDRY_ENDPOINT" = try(module.foundry.foundry_endpoints[0], "")
    "COSMOS_DB_ENDPOINT"  = module.cosmos.cosmos_account_name
    "KEY_VAULT_URI"       = module.key_vault.key_vault_uri
  }

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

# Event Hub Namespace
module "eventhub" {
  source = "./modules/eventhub"

  namespace_name                = var.event_hub_namespace_name != "" ? var.event_hub_namespace_name : "evhns-${local.resource_token}"
  sku                           = var.event_hub_sku
  capacity                      = var.event_hub_capacity_units
  auto_inflate_enabled          = var.event_hub_auto_inflate_enabled
  maximum_throughput_units      = var.event_hub_maximum_throughput_units
  zone_redundant                = var.enable_zone_redundancy
  public_network_access_enabled = !var.enable_private_endpoints
  disable_local_auth            = var.disable_local_auth
  usage_hub_name                = var.usage_event_hub_name
  pii_hub_name                  = var.pii_event_hub_name
  enable_private_endpoints      = var.enable_private_endpoints
  private_endpoint_name         = "pe-eventhub-${local.resource_token}"
  private_endpoint_subnet_id    = module.networking.private_endpoint_subnet_id
  eventhub_private_dns_zone_id  = var.existing_private_dns_zones.event_hub

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

# API Management
module "apim" {
  source = "./modules/apim"

  apim_name                        = var.apim_service_name != "" ? var.apim_service_name : "apim-${local.resource_token}"
  apim_sku                         = "${var.apim_sku}_${var.apim_sku_units}"
  apim_publisher_name              = "AI Foundry Citadel"
  apim_publisher_email             = "noreply@contoso.com"
  apim_network_type                = var.apim_network_type
  apim_subnet_id                   = module.networking.apim_subnet_id
  apim_managed_identity_id         = module.identities.apim_identity_id
  is_apim_v2_sku                   = local.is_apim_v2_sku
  enable_private_endpoints         = var.enable_private_endpoints && local.is_apim_v2_sku
  apim_private_endpoint_name       = "pe-apim-${local.resource_token}"
  apim_private_dns_zone_id         = var.existing_private_dns_zones.apim_gateway
  private_endpoint_subnet_id       = module.networking.private_endpoint_subnet_id
  event_hub_name                   = module.eventhub.usage_hub_name
  event_hub_connection_string      = module.eventhub.apim_connection_string
  app_insights_instrumentation_key = module.monitoring.apim_app_insights_instrumentation_key
  tenant_id                        = data.azurerm_client_config.current.tenant_id
  audience                         = "https://cognitiveservices.azure.com/.default"

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry

  depends_on = [
    module.eventhub
  ]
}

# APIM AI Gateway (APIs, Backends, Policy Fragments)
module "apim_gateway" {
  source = "./modules/apim-gateway"

  apim_service_name                = module.apim.apim_name
  resource_group_name              = azurerm_resource_group.this.name
  apim_managed_identity_client_id  = module.identities.apim_identity_client_id
  llm_backend_config               = local.llm_backend_config
  configure_circuit_breaker        = true
  inference_api_name               = var.inference_api_name
  inference_api_description        = var.inference_api_description
  inference_api_display_name       = var.inference_api_display_name
  inference_api_path               = var.inference_api_path
  inference_api_type               = var.inference_api_type
  allow_subscription_key           = var.allow_subscription_key
  apim_logger_id                   = module.apim.apim_logger_id
  app_insights_id                  = module.monitoring.apim_app_insights_id
  app_insights_instrumentation_key = module.monitoring.apim_app_insights_instrumentation_key

  azure_monitor_log_settings = var.azure_monitor_log_settings
  app_insights_log_settings  = var.app_insights_log_settings

  depends_on = [
    module.apim,
    module.foundry
  ]
}

# ============================================================================
# RBAC: APIM Managed Identity → AOAI + EventHub (Citadel data-plane access)
# ============================================================================

# RBAC: APIM SAMI → Cognitive Services OpenAI User on all AI Foundry endpoints
# Role ID: a97b65f3-2c7c-4a6c-a491-4d188b92e1ab (data-plane role, no condition required per ALZ rules)
resource "azurerm_role_assignment" "apim_to_aoai" {
  for_each = module.foundry.foundry_ids

  scope                = each.value
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.identities.apim_identity_principal_id
  principal_type       = "ServicePrincipal"
}

# RBAC: APIM SAMI → EventHubs Data Sender on namespace
# Role ID: 2b629674-e913-4c01-ae53-ef4638d8f975 (data-plane role, no condition required per ALZ rules)
resource "azurerm_role_assignment" "apim_to_eventhub" {
  scope                = module.eventhub.eventhub_namespace_id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = module.identities.apim_identity_principal_id
  principal_type       = "ServicePrincipal"
}

# Logic App (Usage Ingestion - Consumption tier with Cosmos RBAC)
module "logic_app" {
  source = "./modules/logic-app"

  logic_app_name        = var.usage_logic_app_name != "" ? var.usage_logic_app_name : "logic-${local.resource_token}"
  cosmos_account_name   = module.cosmos.cosmos_account_name
  cosmos_account_id     = module.cosmos.cosmos_account_id
  eventhub_namespace_id = module.eventhub.eventhub_namespace_id

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

# ============================================================================
# PHASE 4: Advanced Features (Redis, API Center)
# ============================================================================

# Managed Redis (optional semantic caching for APIM)
module "redis" {
  count  = var.enable_managed_redis ? 1 : 0
  source = "./modules/redis"

  name                       = var.redis_cache_name != "" ? var.redis_cache_name : "redis-${local.resource_token}"
  sku_name                   = var.redis_sku_name
  sku_capacity               = var.redis_sku_capacity
  minimum_tls_version        = var.redis_minimum_tls_version
  enable_private_endpoint    = var.enable_private_endpoints
  private_endpoint_name      = "pe-redis-${local.resource_token}"
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  redis_private_dns_zone_id  = "" # Redis DNS zone provisioned by networking module if enable_private_endpoints=true

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id
  tags                = local.tags
}
