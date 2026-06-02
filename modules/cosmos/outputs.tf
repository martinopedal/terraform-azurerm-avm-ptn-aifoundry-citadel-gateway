output "cosmos_account_id" {
  value = azurerm_cosmosdb_account.this.id
}

output "cosmos_account_name" {
  value = azurerm_cosmosdb_account.this.name
}

output "database_name" {
  value = azurerm_cosmosdb_sql_database.this.name
}
