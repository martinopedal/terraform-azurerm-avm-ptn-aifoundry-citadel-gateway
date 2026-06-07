locals {
  identity_storage_app_settings = var.storage_uses_managed_identity ? {
    AzureWebJobsStorage__accountName = var.storage_account_name
    AzureWebJobsStorage__credential  = "managedidentity"
  } : {}
}

resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku_name
  tags                = var.tags
}

# Function App (Python 3.11)
resource "azurerm_linux_function_app" "this" {
  name                          = var.function_app_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.this.id
  https_only                    = true
  storage_account_name          = var.storage_account_name
  storage_account_access_key    = var.storage_uses_managed_identity ? null : var.storage_account_access_key
  storage_uses_managed_identity = var.storage_uses_managed_identity
  content_share_force_disabled  = var.content_share_force_disabled

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }
    always_on                              = var.always_on
    vnet_route_all_enabled                 = var.vnet_integration_enabled
    application_insights_connection_string = var.app_insights_connection_string
    application_insights_key               = var.app_insights_key
  }

  app_settings = merge(local.identity_storage_app_settings, {
    "FUNCTIONS_WORKER_RUNTIME"           = "python"
    "PYTHON_ISOLATE_WORKER_DEPENDENCIES" = "1"
  }, var.app_settings)

  tags = var.tags
}

resource "azurerm_role_assignment" "host_storage" {
  for_each = var.storage_uses_managed_identity && var.storage_account_id != "" ? var.host_storage_role_names : toset([])

  scope                = var.storage_account_id
  role_definition_name = each.value
  principal_id         = azurerm_linux_function_app.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# VNet integration
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  count          = var.vnet_integration_enabled ? 1 : 0
  app_service_id = azurerm_linux_function_app.this.id
  subnet_id      = var.function_subnet_id
}
