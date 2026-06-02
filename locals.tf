# ============================================================================
# LOCAL COMPUTATIONS
# ============================================================================

locals {
  # Generate a unique token for resources
  resource_token = lower(substr(sha256("${data.azurerm_subscription.current.subscription_id}-${var.environment_name}-${var.location}"), 0, 13))

  # Resource group name
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "rg-${var.environment_name}"

  # Tags with environment name
  tags = merge(
    var.tags,
    {
      "azd-env-name"    = var.environment_name
      "SecurityControl" = "Ignore"
    }
  )

  # Resolved Entra ID values
  resolved_entra_tenant_id = var.entra_tenant_id != "" ? var.entra_tenant_id : data.azurerm_client_config.current.tenant_id
  resolved_entra_client_id = var.entra_client_id != "" ? var.entra_client_id : "not-configured"
  resolved_entra_audience  = var.entra_audience != "" ? var.entra_audience : (var.entra_auth ? "api://${local.resolved_entra_client_id}" : "https://cognitiveservices.azure.com/.default")

  # API Center location
  apic_location = var.apic_location != "" ? var.apic_location : var.location

  # Private DNS Zone names
  dns_zone_openai             = "privatelink.openai.azure.com"
  dns_zone_key_vault          = "privatelink.vaultcore.azure.net"
  dns_zone_monitor            = "privatelink.monitor.azure.com"
  dns_zone_event_hub          = "privatelink.servicebus.windows.net"
  dns_zone_cosmos_db          = "privatelink.documents.azure.com"
  dns_zone_storage_blob       = "privatelink.blob.core.windows.net"
  dns_zone_storage_file       = "privatelink.file.core.windows.net"
  dns_zone_storage_table      = "privatelink.table.core.windows.net"
  dns_zone_storage_queue      = "privatelink.queue.core.windows.net"
  dns_zone_cognitive_services = "privatelink.cognitiveservices.azure.com"
  dns_zone_apim_v2            = "privatelink.azure-api.net"
  dns_zone_ai_services        = "privatelink.services.ai.azure.com"
  dns_zone_redis              = "privatelink.redis.azure.net"

  # AI Foundry requires 3 DNS zones for full private endpoint support
  ai_foundry_dns_zones = [
    local.dns_zone_cognitive_services,
    local.dns_zone_openai,
    local.dns_zone_ai_services
  ]

  # Base DNS zones (always included)
  base_dns_zones = [
    local.dns_zone_openai,
    local.dns_zone_cognitive_services,
    local.dns_zone_key_vault,
    local.dns_zone_event_hub,
    local.dns_zone_cosmos_db,
    local.dns_zone_storage_blob,
    local.dns_zone_storage_file,
    local.dns_zone_storage_table,
    local.dns_zone_storage_queue,
    local.dns_zone_apim_v2,
    local.dns_zone_ai_services,
    local.dns_zone_redis
  ]

  # Only include Azure Monitor DNS zone when Private Link Scope is enabled
  private_dns_zones = var.use_azure_monitor_private_link_scope ? concat(local.base_dns_zones, [local.dns_zone_monitor]) : local.base_dns_zones

  # Determine if we're using explicit DNS zone resource IDs (BYO network)
  use_explicit_dns_zone_ids = var.existing_private_dns_zones.cosmos_db != "" || var.existing_private_dns_zones.event_hub != "" || var.existing_private_dns_zones.storage_blob != ""

  # AI Foundry DNS zone resource IDs for BYO network scenarios
  ai_foundry_dns_zone_resource_ids = compact([
    var.existing_private_dns_zones.cognitive_services,
    var.existing_private_dns_zones.openai,
    var.existing_private_dns_zones.ai_services
  ])

  # Transform aiFoundryModelsConfig to include the actual aiservice names based on aiservice_index
  transformed_ai_foundry_models_config = [
    for model in var.ai_foundry_models_config : merge(model, {
      aiservice = lookup(model, "aiservice_index", null) != null ? (
        var.ai_foundry_instances[model.aiservice_index].name != "" ?
        var.ai_foundry_instances[model.aiservice_index].name :
        "aif-${local.resource_token}-${model.aiservice_index}"
      ) : ""
    })
  ]

  # Group models by aiservice_index for backend configuration
  models_grouped_by_instance = [
    for i, instance in var.ai_foundry_instances : {
      instance_index = i
      models = [
        for model in var.ai_foundry_models_config :
        {
          name                  = model.name
          sku                   = model.sku
          capacity              = model.capacity
          model_format          = model.publisher
          model_version         = model.version
          retirement_date       = lookup(model, "retirement_date", "")
          api_version           = lookup(model, "api_version", "2024-02-15-preview")
          inference_api_version = lookup(model, "inference_api_version", "")
          timeout               = lookup(model, "timeout", 120)
        }
        if lookup(model, "aiservice_index", null) == i
      ]
    }
  ]

  # Dynamically generate LLM backend configuration from AI Foundry instances and models
  llm_backend_config = [
    for i, instance in var.ai_foundry_instances : {
      backend_id       = instance.name != "" ? "${instance.name}-${i}" : "aif-${local.resource_token}-${i}"
      backend_type     = "ai-foundry"
      endpoint         = "https://${instance.name != "" ? instance.name : "aif-${local.resource_token}-${i}"}.cognitiveservices.azure.com/"
      auth_scheme      = "managedIdentity"
      supported_models = local.models_grouped_by_instance[i].models
      priority         = 1
      weight           = 100
    }
  ]

  # Primary Foundry configuration
  primary_foundry_name                   = var.ai_foundry_instances[0].name != "" ? var.ai_foundry_instances[0].name : "aif-${local.resource_token}-0"
  primary_foundry_endpoint               = "https://${local.primary_foundry_name}.cognitiveservices.azure.com/"
  primary_foundry_embeddings_backend_url = "${local.primary_foundry_endpoint}openai/deployments/${var.primary_foundry_embedding_model_name}/embeddings"

  # Determine if APIM is v2 SKU
  is_apim_v2_sku = contains(["StandardV2", "PremiumV2"], var.apim_sku)
}

# Data sources
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}
