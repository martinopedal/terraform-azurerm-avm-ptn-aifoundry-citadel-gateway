# ============================================================================
# IDENTITIES MODULE - Managed Identities + RBAC
# ============================================================================

# APIM Managed Identity
resource "azurerm_user_assigned_identity" "apim" {
  name                = var.apim_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# cost: RBAC role assignments are free
# Cognitive Services OpenAI User role for APIM identity
resource "azurerm_role_assignment" "apim_cognitive_openai_user" {
  scope                = var.resource_group_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.apim.principal_id
  principal_type       = "ServicePrincipal"
}

# Cognitive Services User role for APIM identity
resource "azurerm_role_assignment" "apim_cognitive_user" {
  scope                = var.resource_group_id
  role_definition_name = "Cognitive Services User"
  principal_id         = azurerm_user_assigned_identity.apim.principal_id
  principal_type       = "ServicePrincipal"
}

# Event Hubs Data Sender role for APIM identity
resource "azurerm_role_assignment" "apim_eventhub_sender" {
  scope                = var.resource_group_id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azurerm_user_assigned_identity.apim.principal_id
  principal_type       = "ServicePrincipal"
}

# Usage Logic App Managed Identity
resource "azurerm_user_assigned_identity" "usage" {
  name                = var.usage_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Cosmos DB Data Contributor role for usage identity (assigned after Cosmos is created)
# This will be wired in main.tf after cosmos module is deployed
