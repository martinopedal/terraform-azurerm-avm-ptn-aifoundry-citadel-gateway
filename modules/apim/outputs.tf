output "apim_id" {
  value = module.apim.resource_id
}

output "apim_name" {
  value = module.apim.name
}

output "apim_gateway_url" {
  value = module.apim.apim_gateway_url
}

output "apim_principal_id" {
  value = try(module.apim.system_assigned_mi_principal_id, "")
}

output "apim_logger_id" {
  description = "Azure Monitor logger resource ID"
  value       = azurerm_api_management_logger.eventhub.id
}
