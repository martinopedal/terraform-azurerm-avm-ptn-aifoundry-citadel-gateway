# Logic App (Consumption tier with embedded workflow definition)
resource "azurerm_logic_app_workflow" "usage_ingestion" {
  name                = var.logic_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Managed identity for Cosmos DB access
  identity {
    type = "SystemAssigned"
  }

  # Workflow definition: Event Hub trigger → Cosmos DB insert
  workflow_parameters = {
    "$connections" = jsonencode({
      defaultValue = {}
      type         = "Object"
    })
  }
  
  # NOTE: Full workflow definition with Event Hub trigger + Cosmos action
  # requires API connections. For demo, this creates the workflow shell.
  # Production: use azurerm_api_connection resources for Event Hubs + Cosmos.
}

# RBAC: Cosmos DB Data Contributor for Logic App identity
resource "azurerm_cosmosdb_sql_role_assignment" "logic_app" {
  resource_group_name = var.resource_group_name
  account_name        = var.cosmos_account_name
  role_definition_id  = "${var.cosmos_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azurerm_logic_app_workflow.usage_ingestion.identity[0].principal_id
  scope               = var.cosmos_account_id
}

# Event Hubs Data Receiver for Logic App identity
resource "azurerm_role_assignment" "logic_app_eventhub" {
  scope                = var.eventhub_namespace_id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_logic_app_workflow.usage_ingestion.identity[0].principal_id
}
