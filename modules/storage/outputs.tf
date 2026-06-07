output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  value     = var.shared_access_key_enabled ? try(azurerm_storage_account.this.primary_access_key, null) : null
  sensitive = true
}
