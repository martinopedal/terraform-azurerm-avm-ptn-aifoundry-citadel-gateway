# Cosmos DB - using azurerm resources directly (AVM module 0.y.z has provider conflicts)
resource "azurerm_cosmosdb_account" "this" {
  name                          = var.cosmos_account_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  public_network_access_enabled = var.cosmos_public_network_access_enabled

  capabilities {
    name = var.cosmos_capacity_mode == "serverless" ? "EnableServerless" : "EnableTable"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.cosmos_capacity_mode == "provisioned" ? var.throughput : null
}

resource "azurerm_cosmosdb_sql_container" "usage" {
  name                = var.container_name_usage
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name
  partition_key_paths = ["/id"]
  throughput          = var.cosmos_capacity_mode == "provisioned" ? var.throughput : null
}

resource "azurerm_cosmosdb_sql_container" "pii" {
  name                = var.container_name_pii
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name
  partition_key_paths = ["/id"]
  throughput          = var.cosmos_capacity_mode == "provisioned" ? var.throughput : null
}

resource "azurerm_cosmosdb_sql_container" "llm" {
  name                = var.container_name_llm
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name
  partition_key_paths = ["/id"]
  throughput          = var.cosmos_capacity_mode == "provisioned" ? var.throughput : null
}

resource "azurerm_private_endpoint" "cosmos" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = var.cosmos_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-cosmos"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.cosmos_private_dns_zone_id != "" ? [var.cosmos_private_dns_zone_id] : []
  }
}
