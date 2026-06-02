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

variable "apim_sku" {
  type        = string
  description = "API Management service SKU."
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

variable "event_hub_capacity_units" {
  type        = number
  description = "Event Hub capacity units."
  default     = 1
}

variable "cosmos_db_rus" {
  type        = number
  description = "Cosmos DB throughput in Request Units (RUs)."
  default     = 400
}

variable "logic_apps_sku_capacity_units" {
  type        = number
  description = "Logic Apps SKU capacity units."
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

variable "redis_sku_name" {
  type        = string
  description = "Redis Enterprise / Azure Managed Redis SKU name."
  default     = "Balanced_B10"
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

variable "ai_foundry_models_config" {
  type = list(object({
    name                  = string
    publisher             = string
    version               = string
    sku                   = string
    capacity              = number
    retirement_date       = optional(string, "")
    api_version           = optional(string, "2024-02-15-preview")
    timeout               = optional(number, 120)
    inference_api_version = optional(string, "")
    aiservice_index       = optional(number)
  }))
  description = "AI Foundry model deployments configuration."
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
# AVM TELEMETRY
# ============================================================================

variable "enable_telemetry" {
  type        = bool
  description = "Enable telemetry for AVM modules."
  default     = true
}
