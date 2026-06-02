output "logic_app_id" {
  value = azurerm_logic_app_workflow.usage_ingestion.id
}

output "logic_app_name" {
  value = azurerm_logic_app_workflow.usage_ingestion.name
}

output "logic_app_principal_id" {
  value = azurerm_logic_app_workflow.usage_ingestion.identity[0].principal_id
}
