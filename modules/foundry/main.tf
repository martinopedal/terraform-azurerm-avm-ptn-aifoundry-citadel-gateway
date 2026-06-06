# AI Foundry (Cognitive Services) - using AzAPI for precise control
resource "azapi_resource" "foundry" {
  for_each  = { for idx, config in var.foundry_instances : idx => config }
  type      = "Microsoft.CognitiveServices/accounts@2024-10-01"
  name      = each.value.name != "" ? each.value.name : "aif-${var.resource_token}-${each.key}"
  location  = each.value.location
  parent_id = var.resource_group_id
  identity { type = "SystemAssigned" }
  body = {
    sku  = { name = "S0" }
    kind = "AIServices"
    properties = {
      customSubDomainName = each.value.custom_sub_domain_name != "" ? each.value.custom_sub_domain_name : null
      publicNetworkAccess = var.foundry_public_network_access_enabled ? "Enabled" : "Disabled"
      disableLocalAuth    = var.disable_local_auth
    }
  }
  tags = var.tags
}

# Model deployments
resource "azapi_resource" "model_deployment" {
  for_each  = { for idx, model in var.model_deployments : "${model.aiservice_index}-${model.name}" => model }
  type      = "Microsoft.CognitiveServices/accounts/deployments@2024-10-01"
  name      = each.value.name
  parent_id = azapi_resource.foundry[each.value.aiservice_index].id

  body = {
    sku = {
      name     = each.value.sku
      capacity = each.value.capacity
    }
    properties = {
      model = {
        format  = each.value.publisher
        name    = each.value.name
        version = each.value.version
      }
    }
  }

  depends_on = [azapi_resource.foundry]
}

# Private endpoints for Foundry (3 DNS zones: cognitive, openai, ai-services)
resource "azurerm_private_endpoint" "foundry" {
  for_each            = var.enable_private_endpoints ? { for idx, config in var.foundry_instances : idx => config } : {}
  name                = "pe-foundry-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = "psc-foundry-${each.key}"
    private_connection_resource_id = azapi_resource.foundry[each.key].id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
  dynamic "private_dns_zone_group" {
    for_each = length(var.foundry_private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.foundry_private_dns_zone_ids
    }
  }
}

# RBAC: Cognitive Services User for APIM
resource "azurerm_role_assignment" "foundry_apim_user" {
  for_each             = { for idx, config in var.foundry_instances : idx => config }
  scope                = azapi_resource.foundry[each.key].id
  role_definition_name = "Cognitive Services User"
  principal_id         = var.apim_principal_id
  principal_type       = "ServicePrincipal"
}
