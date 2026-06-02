# Storage Account for Function App and Logic App
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = var.public_network_access_enabled
  tags                     = var.tags
}
resource "azurerm_storage_container" "function_deployments" {
  name                  = "function-deployments"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
resource "azurerm_private_endpoint" "storage_blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.storage_account_name}-pe-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = "psc-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.storage_blob_private_dns_zone_id != "" ? [var.storage_blob_private_dns_zone_id] : []
  }
}
resource "azurerm_private_endpoint" "storage_file" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.storage_account_name}-pe-file"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = "psc-file"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.storage_file_private_dns_zone_id != "" ? [var.storage_file_private_dns_zone_id] : []
  }
}
