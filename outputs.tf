output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.this.id
}

output "location" {
  description = "The primary location where resources are deployed."
  value       = var.location
}

# Outputs will be added in subsequent phases:
# Phase 2: VNet, Key Vault, Foundry, Cosmos DB
# Phase 3: APIM, API Center
# Phase 4: Event Hub, Storage, Logic App, Redis
