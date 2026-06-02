# ============================================================================
# MONITORING MODULE - Log Analytics + App Insights + Dashboards + AMPLS
# ============================================================================

# Log Analytics Workspace
module "log_analytics" {
  count   = var.use_existing_log_analytics ? 0 : 1
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "~> 0.4.0"

  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # cost: PerGB2018 pricing tier, 30-day retention (free)
  log_analytics_workspace_retention_in_days = var.log_analytics_retention_days
  log_analytics_workspace_sku               = "PerGB2018"
  
  tags             = var.tags
  enable_telemetry = var.enable_telemetry
}

# Reference existing Log Analytics Workspace
data "azurerm_log_analytics_workspace" "existing" {
  count               = var.use_existing_log_analytics ? 1 : 0
  name                = var.existing_log_analytics_name
  resource_group_name = var.existing_log_analytics_rg
}

locals {
  law_id   = var.use_existing_log_analytics ? data.azurerm_log_analytics_workspace.existing[0].id : module.log_analytics[0].resource_id
  law_name = var.use_existing_log_analytics ? data.azurerm_log_analytics_workspace.existing[0].name : module.log_analytics[0].resource.name
}

# Azure Monitor Private Link Scope (optional, for private endpoints)
# cost: AMPLS is free, private endpoint adds ~$7.30/mo
resource "azurerm_monitor_private_link_scope" "this" {
  count               = var.use_azure_monitor_private_link_scope ? 1 : 0
  name                = "ampls-monitoring"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "law" {
  count               = var.use_azure_monitor_private_link_scope ? 1 : 0
  name                = "ampls-law"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this[0].name
  linked_resource_id  = local.law_id
}

# Application Insights - APIM
resource "azurerm_application_insights" "apim" {
  name                = var.apim_app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = local.law_id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "apim_appinsights" {
  count               = var.use_azure_monitor_private_link_scope ? 1 : 0
  name                = "ampls-apim-appinsights"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this[0].name
  linked_resource_id  = azurerm_application_insights.apim.id
}

# Application Insights - Function App
resource "azurerm_application_insights" "function" {
  name                = var.function_app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = local.law_id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "function_appinsights" {
  count               = var.use_azure_monitor_private_link_scope ? 1 : 0
  name                = "ampls-func-appinsights"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this[0].name
  linked_resource_id  = azurerm_application_insights.function.id
}

# Application Insights - Foundry
resource "azurerm_application_insights" "foundry" {
  name                = var.foundry_app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = local.law_id
  application_type    = "other"
  tags                = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "foundry_appinsights" {
  count               = var.use_azure_monitor_private_link_scope ? 1 : 0
  name                = "ampls-foundry-appinsights"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this[0].name
  linked_resource_id  = azurerm_application_insights.foundry.id
}

# Portal Dashboards (optional)
# cost: Dashboards are free
resource "azurerm_portal_dashboard" "apim" {
  count                = var.create_dashboards ? 1 : 0
  name                 = var.apim_dashboard_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  tags                 = var.tags
  dashboard_properties = templatefile("${path.module}/dashboard-apim.tftpl", {
    app_insights_id   = azurerm_application_insights.apim.id
    app_insights_name = azurerm_application_insights.apim.name
    resource_group    = var.resource_group_name
    subscription_id   = data.azurerm_client_config.current.subscription_id
  })
}

resource "azurerm_portal_dashboard" "function" {
  count                = var.create_dashboards ? 1 : 0
  name                 = var.function_dashboard_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  tags                 = var.tags
  dashboard_properties = templatefile("${path.module}/dashboard-function.tftpl", {
    app_insights_id   = azurerm_application_insights.function.id
    app_insights_name = azurerm_application_insights.function.name
    resource_group    = var.resource_group_name
    subscription_id   = data.azurerm_client_config.current.subscription_id
  })
}

resource "azurerm_portal_dashboard" "foundry" {
  count                = var.create_dashboards ? 1 : 0
  name                 = var.foundry_dashboard_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  tags                 = var.tags
  dashboard_properties = templatefile("${path.module}/dashboard-foundry.tftpl", {
    app_insights_id   = azurerm_application_insights.foundry.id
    app_insights_name = azurerm_application_insights.foundry.name
    resource_group    = var.resource_group_name
    subscription_id   = data.azurerm_client_config.current.subscription_id
  })
}

# Private Endpoint for AMPLS (optional)
resource "azurerm_private_endpoint" "ampls" {
  count               = var.use_azure_monitor_private_link_scope && var.enable_private_endpoints ? 1 : 0
  name                = "pe-ampls-monitoring"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-ampls-monitoring"
    private_connection_resource_id = azurerm_monitor_private_link_scope.this[0].id
    is_manual_connection           = false
    subresource_names              = ["azuremonitor"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.monitor_private_dns_zone_id != "" ? [var.monitor_private_dns_zone_id] : []
  }
}

data "azurerm_client_config" "current" {}
