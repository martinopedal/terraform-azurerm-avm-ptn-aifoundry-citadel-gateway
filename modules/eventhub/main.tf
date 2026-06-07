# Event Hub Namespace (using plain azurerm - AVM 0.1.0 too minimal)
resource "azurerm_eventhub_namespace" "this" {
  name                          = var.namespace_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  capacity                      = var.capacity
  auto_inflate_enabled          = var.auto_inflate_enabled
  maximum_throughput_units      = var.auto_inflate_enabled ? var.maximum_throughput_units : null
  public_network_access_enabled = var.public_network_access_enabled
  local_authentication_enabled  = !var.disable_local_auth
  minimum_tls_version           = "1.2"

  dynamic "network_rulesets" {
    for_each = !var.public_network_access_enabled ? [1] : []
    content {
      default_action                 = "Deny"
      public_network_access_enabled  = false
      trusted_service_access_enabled = true
    }
  }

  tags = var.tags
}

# Event Hub for usage tracking
resource "azurerm_eventhub" "usage" {
  name                = var.usage_hub_name
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
  partition_count     = var.usage_partition_count
  message_retention   = var.usage_message_retention
}

# Event Hub for PII tracking
resource "azurerm_eventhub" "pii" {
  name                = var.pii_hub_name
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
  partition_count     = var.pii_partition_count
  message_retention   = var.pii_message_retention
}

# Authorization rule for APIM
resource "azurerm_eventhub_namespace_authorization_rule" "apim" {
  name                = "apim-send"
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name

  listen = false
  send   = true
  manage = false
}

# Private endpoint
resource "azurerm_private_endpoint" "eventhub" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-eventhub"
    private_connection_resource_id = azurerm_eventhub_namespace.this.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.eventhub_private_dns_zone_id != "" ? [var.eventhub_private_dns_zone_id] : []
  }
}
