output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = local.law_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = local.law_name
}

output "apim_app_insights_id" {
  description = "APIM Application Insights ID"
  value       = azurerm_application_insights.apim.id
}

output "apim_app_insights_instrumentation_key" {
  description = "APIM Application Insights instrumentation key"
  value       = azurerm_application_insights.apim.instrumentation_key
  sensitive   = true
}

output "apim_app_insights_connection_string" {
  description = "APIM Application Insights connection string"
  value       = azurerm_application_insights.apim.connection_string
  sensitive   = true
}

output "function_app_insights_id" {
  description = "Function Application Insights ID"
  value       = azurerm_application_insights.function.id
}

output "function_app_insights_instrumentation_key" {
  description = "Function Application Insights instrumentation key"
  value       = azurerm_application_insights.function.instrumentation_key
  sensitive   = true
}

output "function_app_insights_connection_string" {
  description = "Function Application Insights connection string"
  value       = azurerm_application_insights.function.connection_string
  sensitive   = true
}

output "foundry_app_insights_id" {
  description = "Foundry Application Insights ID"
  value       = azurerm_application_insights.foundry.id
}

output "foundry_app_insights_instrumentation_key" {
  description = "Foundry Application Insights instrumentation key"
  value       = azurerm_application_insights.foundry.instrumentation_key
  sensitive   = true
}

output "foundry_app_insights_connection_string" {
  description = "Foundry Application Insights connection string"
  value       = azurerm_application_insights.foundry.connection_string
  sensitive   = true
}
