# Service Plan (Consumption Y1 for Linux)
resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption
  tags                = var.tags
}
# Function App (Python 3.11)
resource "azurerm_linux_function_app" "this" {
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }
    vnet_route_all_enabled                 = var.vnet_integration_enabled
    application_insights_connection_string = var.app_insights_connection_string
    application_insights_key               = var.app_insights_key
  }

  app_settings = merge({
    "FUNCTIONS_WORKER_RUNTIME"           = "python"
    "PYTHON_ISOLATE_WORKER_DEPENDENCIES" = "1"
  }, var.app_settings)

  tags = var.tags
}
# VNet integration
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  count          = var.vnet_integration_enabled ? 1 : 0
  app_service_id = azurerm_linux_function_app.this.id
  subnet_id      = var.function_subnet_id
}
