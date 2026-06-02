output "eventhub_namespace_id" {
  value = azurerm_eventhub_namespace.this.id
}

output "eventhub_namespace_name" {
  value = azurerm_eventhub_namespace.this.name
}

output "usage_hub_name" {
  value = azurerm_eventhub.usage.name
}

output "pii_hub_name" {
  value = azurerm_eventhub.pii.name
}

output "apim_connection_string" {
  value     = azurerm_eventhub_namespace_authorization_rule.apim.primary_connection_string
  sensitive = true
}
