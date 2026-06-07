# Key Vault using AVM
module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = ">= 0.9.0, < 1.0.0"

  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                        = var.key_vault_sku_name
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = true
  legacy_access_policies_enabled  = false # Use RBAC instead
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  public_network_access_enabled   = var.key_vault_public_network_access_enabled

  network_acls     = var.key_vault_public_network_access_enabled ? null : { bypass = "AzureServices", default_action = "Deny" }
  tags             = var.tags
  enable_telemetry = var.enable_telemetry
}
resource "azurerm_private_endpoint" "kv" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = var.key_vault_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = "psc-kv"
    private_connection_resource_id = module.key_vault.resource_id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.key_vault_private_dns_zone_id != "" ? [var.key_vault_private_dns_zone_id] : []
  }
}
resource "azurerm_role_assignment" "apim_kv_secrets_user" {
  scope                = module.key_vault.resource_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.apim_principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_key_vault_secret" "entra_client_secret" {
  count        = var.entra_client_secret != "" ? 1 : 0
  name         = "ENTRA-APP-CLIENT-SECRET"
  value        = var.entra_client_secret
  key_vault_id = module.key_vault.resource_id
}
data "azurerm_client_config" "current" {}
