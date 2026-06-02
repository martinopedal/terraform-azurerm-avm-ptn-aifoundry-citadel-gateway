# ============================================================================
# NETWORKING MODULE - Outputs
# ============================================================================

output "vnet_id" {
  description = "VNet resource ID"
  value       = var.create_new_vnet ? module.vnet[0].resource_id : data.azurerm_virtual_network.existing[0].id
}

output "vnet_name" {
  description = "VNet name"
  value       = var.create_new_vnet ? module.vnet[0].name : data.azurerm_virtual_network.existing[0].name
}

output "vnet_resource_group_name" {
  description = "VNet resource group name"
  value       = var.create_new_vnet ? var.resource_group_name : var.existing_vnet_resource_group_name
}

output "apim_subnet_id" {
  description = "APIM subnet ID"
  value       = var.create_new_vnet ? azurerm_subnet.apim[0].id : data.azurerm_subnet.apim_existing[0].id
}

output "private_endpoint_subnet_id" {
  description = "Private endpoint subnet ID"
  value       = var.create_new_vnet ? azurerm_subnet.private_endpoint[0].id : data.azurerm_subnet.private_endpoint_existing[0].id
}

output "function_app_subnet_id" {
  description = "Function app subnet ID"
  value       = var.create_new_vnet ? azurerm_subnet.function_app[0].id : data.azurerm_subnet.function_app_existing[0].id
}

output "agent_subnet_id" {
  description = "Agent subnet ID (empty if not enabled)"
  value       = var.enable_agent_subnet ? (var.create_new_vnet ? azurerm_subnet.agent[0].id : data.azurerm_subnet.agent_existing[0].id) : ""
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone names to IDs (only for new VNet)"
  value       = var.create_new_vnet ? { for k, v in azurerm_private_dns_zone.this : k => v.id } : {}
}
