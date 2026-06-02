# ============================================================================
# BASIC PARAMETERS
# ============================================================================

variable "environment_name" {
  type        = string
  description = "Name of the environment which is used to generate a short unique hash used in all resources."
  validation {
    condition     = length(var.environment_name) >= 1 && length(var.environment_name) <= 64
    error_message = "Environment name must be between 1 and 64 characters."
  }
}

variable "location" {
  type        = string
  description = "Primary location for all resources (filtered on available regions for Azure OpenAI Service)."
  validation {
    condition = contains([
      "uaenorth", "southafricanorth", "westeurope", "southcentralus",
      "australiaeast", "canadaeast", "eastus", "eastus2", "francecentral",
      "japaneast", "northcentralus", "swedencentral", "switzerlandnorth", "uksouth"
    ], var.location)
    error_message = "Location must be an Azure OpenAI Service supported region."
  }
}

variable "apic_location" {
  type        = string
  description = "Location of the API Center service. Leave blank to use primary location, where API Center is available in that region."
  default     = ""
  validation {
    condition = var.apic_location == "" || contains([
      "australiaeast", "canadacentral", "centralindia", "eastus",
      "francecentral", "swedencentral", "uksouth", "westeurope"
    ], var.apic_location)
    error_message = "API Center location must be empty or a supported region."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources."
  default     = {}
}

# ============================================================================
# RESOURCE NAMES
# ============================================================================

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group. Leave blank to use default naming conventions."
  default     = ""
}

variable "apim_identity_name" {
  type        = string
  description = "Name of the APIM managed identity. Leave blank to use default naming conventions."
  default     = ""
}

variable "usage_logic_app_identity_name" {
  type        = string
  description = "Name of the Usage Logic App managed identity. Leave blank to use default naming conventions."
  default     = ""
}

variable "apim_service_name" {
  type        = string
  description = "Name of the API Management service. Leave blank to use default naming conventions."
  default     = ""
}

variable "log_analytics_name" {
  type        = string
  description = "Name of the Log Analytics workspace. Leave blank to use default naming conventions."
  default     = ""
}

variable "use_existing_log_analytics" {
  type        = bool
  description = "Use an existing Log Analytics workspace instead of creating a new one."
  default     = false
}

variable "existing_log_analytics_name" {
  type        = string
  description = "Name of the existing Log Analytics workspace (only used when use_existing_log_analytics is true)."
  default     = ""
}

variable "existing_log_analytics_rg" {
  type        = string
  description = "Resource group containing the existing Log Analytics workspace (only used when use_existing_log_analytics is true)."
  default     = ""
}

variable "existing_log_analytics_subscription_id" {
  type        = string
  description = "Subscription ID containing the existing Log Analytics workspace (only used when use_existing_log_analytics is true). Leave blank to use the current subscription."
  default     = ""
}

variable "key_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault. Leave blank to use default naming conventions."
  default     = ""
}

variable "ai_foundry_resource_name" {
  type        = string
  description = "Name of the AI Foundry resource. Leave blank to use default naming conventions."
  default     = ""
}

variable "event_hub_namespace_name" {
  type        = string
  description = "Name of the Event Hub Namespace resource. Leave blank to use default naming conventions."
  default     = ""
}

variable "cosmos_db_account_name" {
  type        = string
  description = "Name of the Cosmos DB account resource. Leave blank to use default naming conventions."
  default     = ""
}

variable "usage_processing_logic_app_name" {
  type        = string
  description = "Name of the Logic App resource for usage processing. Leave blank to use default naming conventions."
  default     = ""
}

variable "storage_account_name" {
  type        = string
  description = "Name of the Storage Account. Leave blank to use default naming conventions."
  default     = ""
}

variable "apic_service_name" {
  type        = string
  description = "Name of the API Center service. Leave blank to use default naming conventions."
  default     = ""
}

variable "redis_cache_name" {
  type        = string
  description = "Name of the Azure Managed Redis resource. Leave blank to use default naming conventions."
  default     = ""
}

# ============================================================================
# NETWORKING PARAMETERS
# ============================================================================

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network. Leave blank to use default naming conventions."
  default     = ""
}

variable "use_existing_vnet" {
  type        = bool
  description = "Use an existing Virtual Network instead of creating a new one."
  default     = false
}

variable "existing_vnet_rg" {
  type        = string
  description = "Resource group containing the existing VNet (only used when use_existing_vnet is true)."
  default     = ""
}

variable "apim_subnet_name" {
  type        = string
  description = "Subnet name for API Management in the VNet. Leave blank to use default naming conventions."
  default     = ""
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name for Private Endpoints in the VNet. Leave blank to use default naming conventions."
  default     = ""
}

variable "function_app_subnet_name" {
  type        = string
  description = "Subnet name for Function/Logic App in the VNet. Leave blank to use default naming conventions."
  default     = ""
}

variable "agent_subnet_name" {
  type        = string
  description = "Subnet name for AI Foundry agent (network injection) workloads in the VNet. Required when foundry_network_injection_enabled is true and use_existing_vnet is true."
  default     = ""
}

variable "vnet_address_prefix" {
  type        = string
  description = "Virtual Network address space."
  default     = "10.170.0.0/24"
}

variable "apim_subnet_prefix" {
  type        = string
  description = "API Management subnet address range."
  default     = "10.170.0.0/26"
}

variable "private_endpoint_subnet_prefix" {
  type        = string
  description = "Private Endpoint subnet address range."
  default     = "10.170.0.64/26"
}

variable "function_app_subnet_prefix" {
  type        = string
  description = "Function App subnet address range."
  default     = "10.170.0.128/26"
}

variable "agent_subnet_prefix" {
  type        = string
  description = "AI Foundry agent (network injection) subnet address range. Used only when a new VNet is provisioned and foundry_network_injection_enabled is true. Subnet is delegated to Microsoft.App/environments."
  default     = "10.170.0.192/26"
}

variable "foundry_network_injection_enabled" {
  type        = bool
  description = "Enable AI Foundry network injection by attaching the Foundry account to the agent subnet (delegated to Microsoft.App/environments). When use_existing_vnet is true the agent_subnet_name must reference an existing subnet with the required delegation."
  default     = true
}

# DNS ZONE PARAMETERS
variable "existing_private_dns_zones" {
  type = object({
    openai             = optional(string, "")
    key_vault          = optional(string, "")
    monitor            = optional(string, "")
    event_hub          = optional(string, "")
    cosmos_db          = optional(string, "")
    storage_blob       = optional(string, "")
    storage_file       = optional(string, "")
    storage_table      = optional(string, "")
    storage_queue      = optional(string, "")
    cognitive_services = optional(string, "")
    apim_gateway       = optional(string, "")
    ai_services        = optional(string, "")
    redis              = optional(string, "")
  })
  description = "Existing Private DNS Zone resource IDs for BYO network scenarios. Each property should contain the full resource ID of the DNS zone."
  default     = {}
}

# Network access configuration
variable "apim_network_type" {
  type        = string
  description = "Network type for API Management service. Applies only to Premium and Developer SKUs."
  default     = "External"
  validation {
    condition     = contains(["External", "Internal"], var.apim_network_type)
    error_message = "APIM network type must be External or Internal."
  }
}

variable "apim_v2_use_private_endpoint" {
  type        = bool
  description = "Use private endpoint for API Management service. Applies only to StandardV2 and PremiumV2 SKUs."
  default     = true
}

variable "apim_v2_public_network_access" {
  type        = bool
  description = "API Management service external network access. When false, APIM must have private endpoint."
  default     = true
}

variable "cosmos_db_public_access" {
  type        = string
  description = "Cosmos DB public network access."
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.cosmos_db_public_access)
    error_message = "Cosmos DB public access must be Enabled or Disabled."
  }
}

variable "event_hub_network_access" {
  type        = string
  description = "Event Hub public network access. Needed to be Enabled when using APIM v2 SKUs during provisioning."
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.event_hub_network_access)
    error_message = "Event Hub network access must be Enabled or Disabled."
  }
}

variable "ai_foundry_external_network_access" {
  type        = string
  description = "AI Foundry external network access."
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.ai_foundry_external_network_access)
    error_message = "AI Foundry external network access must be Enabled or Disabled."
  }
}

variable "key_vault_external_network_access" {
  type        = string
  description = "Key Vault external network access."
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.key_vault_external_network_access)
    error_message = "Key Vault external network access must be Enabled or Disabled."
  }
}

variable "redis_public_network_access" {
  type        = string
  description = "Azure Managed Redis public network access. When Disabled, private endpoint is the exclusive access method."
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.redis_public_network_access)
    error_message = "Redis public network access must be Enabled or Disabled."
  }
}

variable "use_azure_monitor_private_link_scope" {
  type        = bool
  description = "Use Azure Monitor Private Link Scope for Log Analytics and Application Insights."
  default     = false
}

# ============================================================================
# FEATURE FLAGS
# ============================================================================

variable "create_app_insights_dashboards" {
  type        = bool
  description = "Create Application Insights dashboards."
  default     = false
}

variable "enable_ai_model_inference" {
  type        = bool
  description = "Enable AI Model Inference in API Management."
  default     = true
}

variable "enable_document_intelligence" {
  type        = bool
  description = "Enable Document Intelligence in API Management."
  default     = true
}

variable "enable_azure_ai_search" {
  type        = bool
  description = "Enable Azure AI Search integration."
  default     = true
}

variable "enable_ai_gateway_pii_redaction" {
  type        = bool
  description = "Enable PII redaction in AI Gateway."
  default     = true
}

variable "enable_openai_realtime" {
  type        = bool
  description = "Enable OpenAI realtime capabilities."
  default     = true
}

variable "entra_auth" {
  type        = bool
  description = "Enable Microsoft Entra ID authentication for API Management."
  default     = true
}

variable "enable_api_center" {
  type        = bool
  description = "Enable API Center for API governance and discovery."
  default     = true
}

variable "enable_managed_redis" {
  type        = bool
  description = "Enable Azure Managed Redis (AMR). When true, the Redis resource and APIM cache integration are provisioned."
  default     = false
}

variable "enable_unified_ai_api" {
  type        = bool
  description = "Enable the Unified AI Wildcard API (3rd API alongside Azure OpenAI and Universal LLM)."
  default     = true
}

# ============================================================================
# COMPUTE SKU & SIZE
# ============================================================================

# cost: APIM Developer (~$50/mo) supports VNet injection + AI gateway policies + logger/diagnostics.
# Does NOT support multi-region, zone redundancy, or Premium-only features (cache, VPN).
# For production: StandardV2 (~$700/mo) or Premium (~$2.8k/mo) via variable override.
variable "apim_sku" {
  type        = string
  description = "API Management service SKU. Developer is cheapest for demo (VNet-capable, ~$50/mo). StandardV2/Premium for production."
  default     = "Developer"
  validation {
    condition     = contains(["Developer", "Premium", "StandardV2", "PremiumV2"], var.apim_sku)
    error_message = "APIM SKU must be Developer, Premium, StandardV2, or PremiumV2."
  }
}

variable "apim_sku_units" {
  type        = number
  description = "API Management service SKU units."
  default     = 1
}

# cost: Event Hub Basic (no capture, 1-day retention, ~$10/mo base) or Standard (7-day, ~$25/mo base).
# 1 TU = ~1 MB/s ingress, 2 MB/s egress. For demo usage ingestion (low volume), 1 TU is sufficient.
variable "event_hub_sku" {
  type        = string
  description = "Event Hub SKU. Basic (~$10/mo) for demo, Standard (~$25/mo) for capture/longer retention."
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.event_hub_sku)
    error_message = "Event Hub SKU must be Basic, Standard, or Premium."
  }
}

variable "event_hub_capacity_units" {
  type        = number
  description = "Event Hub capacity units (throughput units). 1 TU = 1 MB/s in, 2 MB/s out. Default 1 for demo."
  default     = 1
}

variable "event_hub_auto_inflate_enabled" {
  type        = bool
  description = "Enable auto-inflate for Event Hub (Standard/Premium only). Default OFF for cost control."
  default     = false
}

# cost: Cosmos DB serverless (~$0 base, pay-per-RU consumed) is cheapest for demo/low-volume analytics.
# Provisioned (RU/s) starts at 400 RUs (~$24/mo). Serverless has 5k RU/s burst limit.
# For demo usage analytics (write-heavy, low query volume), serverless is optimal.
variable "cosmos_capacity_mode" {
  type        = string
  description = "Cosmos DB capacity mode. Serverless (~$0 base, pay-per-RU) for demo, Provisioned for predictable workloads."
  default     = "serverless"
  validation {
    condition     = contains(["serverless", "provisioned"], var.cosmos_capacity_mode)
    error_message = "Cosmos capacity mode must be serverless or provisioned."
  }
}

variable "cosmos_db_rus" {
  type        = number
  description = "Cosmos DB throughput in Request Units (RUs). Only used when cosmos_capacity_mode = provisioned. Minimum 400."
  default     = 400
}

# cost: Logic App Consumption (pay-per-execution, ~$0.000025/action) vs Standard/WS1 (~$200/mo base + compute).
# The Bicep accelerator uses WorkflowStandard (WS1) for VNet integration + private endpoints.
# RESEARCH NEEDED: Can usage ingestion workflow run on Consumption? If yes, change default.
# For now, keeping WS1 as Bicep does, but flagging for Phase 4 review.
variable "logic_apps_sku" {
  type        = string
  description = "Logic Apps SKU. WS1 (WorkflowStandard, ~$200/mo) for VNet integration. Consumption for cheapest (if no VNet needed)."
  default     = "WS1"
  validation {
    condition     = contains(["WS1", "WS2", "WS3"], var.logic_apps_sku)
    error_message = "Logic Apps SKU must be WS1, WS2, or WS3 for WorkflowStandard."
  }
}

variable "logic_apps_sku_capacity_units" {
  type        = number
  description = "Logic Apps SKU capacity units (WorkflowStandard only). Default 1 for demo."
  default     = 1
}

variable "apic_sku" {
  type        = string
  description = "SKU for the API Center service."
  default     = "Free"
  validation {
    condition     = contains(["Free", "Standard"], var.apic_sku)
    error_message = "API Center SKU must be Free or Standard."
  }
}

variable "key_vault_sku_name" {
  type        = string
  description = "SKU for the Key Vault service."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "Key Vault SKU must be standard or premium."
  }
}

# cost: Redis Balanced_B1 (~$200/mo, 1 GB cache, 1k ops/s) is cheapest for semantic cache demo.
# Balanced_B10 (~$2k/mo, 10 GB) is overkill for demo. Default to B1 when enabled.
variable "redis_sku_name" {
  type        = string
  description = "Redis Enterprise / Azure Managed Redis SKU name. Balanced_B1 (~$200/mo, 1 GB) is cheapest for demo."
  default     = "Balanced_B1"
}

variable "redis_sku_capacity" {
  type        = number
  description = "Redis Enterprise cluster capacity. Only used for Enterprise_* and EnterpriseFlash_* SKUs."
  default     = 2
}

variable "redis_minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for Redis connections."
  default     = "1.2"
}

# ============================================================================
# AI BACKENDS CONFIGURATION
# ============================================================================

variable "ai_search_instances" {
  type = list(object({
    name        = string
    url         = string
    description = string
  }))
  description = "AI Search instances configuration."
  default     = []
}

variable "ai_foundry_instances" {
  type = list(object({
    name                      = string
    location                  = string
    custom_sub_domain_name    = optional(string, "")
    default_project_name      = string
    network_injection_enabled = optional(bool, true)
  }))
  description = "AI Foundry instances configuration array. The first element is the primary Foundry resource."
  default     = []
}

# cost: Model deployments default to Standard (pay-per-token) with minimal capacity (1k-10k TPM).
# gpt-4o-mini is cheapest ($0.15/1M input, $0.60/1M output) vs gpt-4o ($2.50/1M input, $10/1M output).
# GlobalStandard = global load balancing, same price as Standard.
# For demo, use gpt-4o-mini + text-embedding-3-small (if embeddings needed).
variable "ai_foundry_models_config" {
  type = list(object({
    name                  = string
    publisher             = string
    version               = string
    sku                   = string # Standard or GlobalStandard (pay-per-token)
    capacity              = number # TPM quota: 1k-10k for demo, 100k+ for prod
    retirement_date       = optional(string, "")
    api_version           = optional(string, "2024-02-15-preview")
    timeout               = optional(number, 120)
    inference_api_version = optional(string, "")
    aiservice_index       = optional(number)
  }))
  description = "AI Foundry model deployments. Default to Standard (pay-per-token) + minimal capacity (1k-10k TPM) + cheap models (gpt-4o-mini)."
  default     = []
}

variable "primary_foundry_embedding_model_name" {
  type        = string
  description = "Name of the text embedding model deployment in the primary Microsoft Foundry to be used for APIM semantic caching."
  default     = "text-embedding-3-large"
}

# ============================================================================
# ENTRA ID PARAMETERS
# ============================================================================

variable "entra_tenant_id" {
  type        = string
  description = "Microsoft Entra ID tenant ID for authentication (only used when entra_auth is true)."
  default     = ""
}

variable "entra_client_id" {
  type        = string
  description = "Microsoft Entra ID client ID for authentication (only used when entra_auth is true). If empty and entra_auth is true, an app registration must be pre-provisioned."
  default     = ""
}

variable "entra_audience" {
  type        = string
  description = "Audience value for Microsoft Entra ID authentication (only used when entra_auth is true)."
  default     = ""
}

variable "entra_client_secret" {
  type        = string
  description = "Entra ID client secret for the app registration (only used when entra_auth is true with a pre-existing app registration)."
  default     = ""
  sensitive   = true
}

# ============================================================================
# SECURITY TOGGLES (Cheap/Permissive Default, Opt-In to Harden)
# ============================================================================

# cost: Private endpoints = $7.30/mo each. 10 PEs = ~$70/mo. Default TRUE per ALZ private-by-default,
# but disabling saves ~$70/mo if public network access is acceptable for demo.
variable "enable_private_endpoints" {
  type        = bool
  description = "Enable private endpoints for all resources (Foundry, Key Vault, Cosmos, Event Hub, Storage, APIM v2, Redis). Adds ~$7.30/mo per PE (~$70/mo total). Default TRUE per ALZ private-by-default posture. Set FALSE to save cost in non-prod."
  default     = true
}

# cost: Free. Disables key-based auth, requires AAD tokens. Default FALSE for demo simplicity (allow keys).
# Production: TRUE for zero-trust posture.
variable "disable_local_auth" {
  type        = bool
  description = "Disable local/key-based authentication on supported resources (Cosmos, Storage, Event Hub, Key Vault). Requires AAD-only access. Default FALSE (allow keys) for demo simplicity. Production: TRUE."
  default     = false
}

# cost: Extra Key Vault operations (~$0.03/10k ops, minimal). Default FALSE for demo simplicity.
# Production: TRUE for compliance (CMEK = customer-managed encryption keys).
variable "enable_customer_managed_keys" {
  type        = bool
  description = "Enable customer-managed encryption keys (CMEK) via Key Vault for supported resources (Cosmos, Storage, Event Hub). Adds Key Vault ops cost (~$0.03/10k ops, minimal). Default FALSE. Production: TRUE for compliance."
  default     = false
}

# ============================================================================
# RELIABILITY TOGGLES (Cheap Single-Instance Default, Opt-In to Harden)
# ============================================================================

# cost: Zone redundancy requires SKU bump for most resources:
# - APIM: Developer (no zones) -> StandardV2/PremiumV2 (+$650-2750/mo)
# - Event Hub: Standard (no zones) -> Premium (+$625/mo)
# - Storage: LRS (no zones) -> ZRS (+minimal, ~$0.002/GB delta)
# - Cosmos: single-region -> multi-region + zone redundancy (pay per region + RUs)
# Default FALSE. Production: TRUE + bump SKUs.
variable "enable_zone_redundancy" {
  type        = bool
  description = "Enable Availability Zone redundancy where supported. Requires SKU bumps: APIM Developer->StandardV2 (+$650/mo), Event Hub Standard->Premium (+$625/mo), Storage LRS->ZRS (minimal), Cosmos multi-region. Default FALSE. Production: TRUE + upgrade SKUs."
  default     = false
}

# cost: Free (30-day retention). 31-365 days = $0.12/GB/month extra.
# Already defined above, but documenting here for clarity.
variable "log_analytics_retention_days" {
  type        = number
  description = "Log Analytics workspace data retention in days. 30 days = free. 31-365 days = $0.12/GB/month. Default 30 for demo."
  default     = 30
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

# cost: Cosmos serverless has 7-day point-in-time restore included. Continuous backup (30-day) requires provisioned mode.
# Default = periodic (7-day) for serverless. Production: continuous (30-day) with provisioned mode.
variable "cosmos_backup_type" {
  type        = string
  description = "Cosmos DB backup type. Periodic (7-day, included with serverless) or Continuous (30-day, requires provisioned mode). Default Periodic for demo cost."
  default     = "Periodic"
  validation {
    condition     = contains(["Periodic", "Continuous"], var.cosmos_backup_type)
    error_message = "Cosmos backup type must be Periodic or Continuous."
  }
}

# cost: Storage soft delete is free (7-day default). Extend for compliance.
variable "storage_soft_delete_days" {
  type        = number
  description = "Storage Account blob soft delete retention days. Free for 1-365 days. Default 7 for demo. Production: 30-90 days."
  default     = 7
  validation {
    condition     = var.storage_soft_delete_days >= 1 && var.storage_soft_delete_days <= 365
    error_message = "Storage soft delete retention must be between 1 and 365 days."
  }
}

# ============================================================================
# AVM TELEMETRY
# ============================================================================

variable "enable_telemetry" {
  type        = bool
  description = "Enable telemetry for AVM modules."
  default     = true
}
