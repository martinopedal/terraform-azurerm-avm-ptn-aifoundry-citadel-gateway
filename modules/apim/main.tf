# API Management using AVM
module "apim" {
  source  = "Azure/avm-res-apimanagement-service/azurerm"
  version = "~> 0.9.0"

  name                = var.apim_name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = var.apim_sku

  # VNet integration
  virtual_network_type      = var.apim_network_type
  virtual_network_subnet_id = var.apim_network_type != "None" ? var.apim_subnet_id : null

  # Managed identity
  managed_identities = {
    user_assigned_resource_ids = [var.apim_managed_identity_id]
  }

  tags             = var.tags
  enable_telemetry = var.enable_telemetry
}

# APIM Logger for Event Hub (usage tracking)
resource "azurerm_api_management_logger" "eventhub" {
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
  name                = "appinsights-logger"
  api_management_name = module.apim.name
  resource_group_name = var.resource_group_name

  application_insights {
    instrumentation_key = var.app_insights_instrumentation_key
  }
}

# Named values for configuration
resource "azurerm_api_management_named_value" "tenant_id" {
  name                = "tenant-id"
  resource_group_name = var.resource_group_name
  api_management_name = module.apim.name
  display_name        = "tenant-id"
  value               = var.tenant_id
}

resource "azurerm_api_management_named_value" "audience" {
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

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.apim_private_dns_zone_id != "" ? [var.apim_private_dns_zone_id] : []
  }
}

data "azurerm_client_config" "current" {}
