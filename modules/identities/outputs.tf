output "apim_identity_id" {
  description = "APIM managed identity resource ID"
  value       = azurerm_user_assigned_identity.apim.id
}

output "apim_identity_principal_id" {
  description = "APIM managed identity principal ID"
  value       = azurerm_user_assigned_identity.apim.principal_id
}

output "apim_identity_client_id" {
  description = "APIM managed identity client ID"
  value       = azurerm_user_assigned_identity.apim.client_id
}

output "usage_identity_id" {
  description = "Usage managed identity resource ID"
  value       = azurerm_user_assigned_identity.usage.id
}

output "usage_identity_principal_id" {
  description = "Usage managed identity principal ID"
  value       = azurerm_user_assigned_identity.usage.principal_id
}

output "usage_identity_client_id" {
  description = "Usage managed identity client ID"
  value       = azurerm_user_assigned_identity.usage.client_id
}
