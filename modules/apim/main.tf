# API Management using AVM
locals {
  apim_is_v2_sku = var.is_apim_v2_sku

  apim_managed_identities = {
    system_assigned            = var.apim_system_assigned_identity
    user_assigned_resource_ids = var.apim_managed_identity_id != "" ? [var.apim_managed_identity_id] : []
  }

  create_eventhub_logger    = var.event_hub_name != ""
  create_appinsights_logger = var.app_insights_instrumentation_key != ""
  create_tenant_named_value = var.tenant_id != ""
}

module "apim" {
  source  = "Azure/avm-res-apimanagement-service/azurerm"
  version = "~> 0.9.0"

  name                          = var.apim_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  publisher_name                = var.apim_publisher_name
  publisher_email               = var.apim_publisher_email
  sku_name                      = var.apim_sku
  public_network_access_enabled = var.public_network_access_enabled

  # Standard v2 outbound VNet integration is applied through AzAPI below.
  virtual_network_type      = local.apim_is_v2_sku ? "None" : var.apim_network_type
  virtual_network_subnet_id = !local.apim_is_v2_sku && var.apim_network_type != "None" ? var.apim_subnet_id : null

  # Managed identity
  managed_identities = local.apim_managed_identities

  tags             = var.tags
  enable_telemetry = var.enable_telemetry
}

resource "azapi_update_resource" "apim_v2_vnet_integration" {
  count       = local.apim_is_v2_sku && var.apim_network_type != "None" && var.apim_subnet_id != "" ? 1 : 0
  type        = "Microsoft.ApiManagement/service@2024-06-01-preview"
  resource_id = module.apim.resource_id

  body = {
    properties = {
      virtualNetworkType = var.apim_network_type
      virtualNetworkConfiguration = {
        subnetResourceId = var.apim_subnet_id
      }
    }
  }
}

# APIM Logger for Event Hub (usage tracking)
resource "azurerm_api_management_logger" "eventhub" {
  count               = local.create_eventhub_logger ? 1 : 0
  name                = "eventhub-logger"
  api_management_name = module.apim.name
  resource_group_name = var.resource_group_name

  eventhub {
    name              = var.event_hub_name
    connection_string = var.event_hub_connection_string
  }
}

# App Insights integration
resource "azurerm_api_management_logger" "appinsights" {
  count               = local.create_appinsights_logger ? 1 : 0
  name                = "appinsights-logger"
  api_management_name = module.apim.name
  resource_group_name = var.resource_group_name

  application_insights {
    instrumentation_key = var.app_insights_instrumentation_key
  }
}

# Named values for configuration
resource "azurerm_api_management_named_value" "tenant_id" {
  count               = local.create_tenant_named_value ? 1 : 0
  name                = "tenant-id"
  resource_group_name = var.resource_group_name
  api_management_name = module.apim.name
  display_name        = "tenant-id"
  value               = var.tenant_id
}

resource "azurerm_api_management_named_value" "audience" {
  count               = local.create_tenant_named_value ? 1 : 0
  name                = "audience"
  resource_group_name = var.resource_group_name
  api_management_name = module.apim.name
  display_name        = "audience"
  value               = var.audience
}

# Private endpoint for APIM v2 SKU
resource "azurerm_private_endpoint" "apim" {
  count               = var.is_apim_v2_sku && var.enable_private_endpoints ? 1 : 0
  name                = var.apim_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-apim"
    private_connection_resource_id = module.apim.resource_id
    is_manual_connection           = false
    subresource_names              = ["Gateway"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.apim_private_dns_zone_id != "" ? [var.apim_private_dns_zone_id] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [private_dns_zone_group.value]
    }
  }

  depends_on = [azapi_update_resource.apim_v2_vnet_integration]
}

resource "azurerm_role_assignment" "cognitive_services_user" {
  for_each = var.cognitive_services_user_scope_ids

  scope                = each.value
  role_definition_name = "Cognitive Services User"
  principal_id         = module.apim.workspace_identity.principal_id
  principal_type       = "ServicePrincipal"
}

data "azurerm_client_config" "current" {}
