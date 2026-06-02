# Logic App (Consumption) - stub for Phase 3 validation
# Full workflow implementation deferred
resource "azurerm_logic_app_workflow" "usage_ingestion" {
  name                = var.logic_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
