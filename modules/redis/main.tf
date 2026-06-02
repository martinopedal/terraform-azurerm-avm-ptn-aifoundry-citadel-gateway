# ============================================================================
# Azure Managed Redis Enterprise Module
# Port of bicep/infra/modules/redis/redis.bicep from upstream citadel-v1
# ============================================================================

terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# ============================================================================
# Redis Enterprise Cluster
# API: Microsoft.Cache/redisEnterprise@2025-07-01
# ============================================================================

resource "azapi_resource" "redis_enterprise" {
  type      = "Microsoft.Cache/redisEnterprise@2025-07-01"
  name      = var.name
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags

  body = {
    sku = var.sku_name == "Balanced_B1" ? {
      name = var.sku_name
      } : (
      startswith(var.sku_name, "Enterprise_") || startswith(var.sku_name, "EnterpriseFlash_") ? {
        name     = var.sku_name
        capacity = var.sku_capacity
        } : {
        name = var.sku_name
      }
    )
    properties = {
      minimumTlsVersion   = var.minimum_tls_version
      publicNetworkAccess = var.public_network_access
    }
  }
}

# ============================================================================
# Redis Database with RediSearch Module
# ============================================================================

resource "azapi_resource" "redis_database" {
  type      = "Microsoft.Cache/redisEnterprise/databases@2025-07-01"
  name      = "default"
  parent_id = azapi_resource.redis_enterprise.id

  body = {
    properties = {
      accessKeysAuthentication = "Enabled"
      evictionPolicy           = "NoEviction"
      clusteringPolicy         = "EnterpriseCluster"
      clientProtocol           = "Encrypted"
      modules = [
        {
          name = "RediSearch"
        }
      ]
      port = 10000
    }
  }

  response_export_values = ["properties.hostName", "properties.port"]
}

# ============================================================================
# Private Endpoint (if enabled)
# ============================================================================

resource "azurerm_private_endpoint" "redis" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-redis"
    private_connection_resource_id = azapi_resource.redis_enterprise.id
    is_manual_connection           = false
    subresource_names              = ["redisEnterprise"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.redis_private_dns_zone_id != "" ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.redis_private_dns_zone_id]
    }
  }
}

# ============================================================================
# Retrieve Redis Keys (data plane)
# ============================================================================

data "azapi_resource_action" "redis_keys" {
  type                   = "Microsoft.Cache/redisEnterprise/databases@2025-07-01"
  resource_id            = azapi_resource.redis_database.id
  action                 = "listKeys"
  response_export_values = ["primaryKey", "secondaryKey"]
}

# ============================================================================
# Locals for connection string assembly
# ============================================================================

locals {
  redis_hostname    = jsondecode(azapi_resource.redis_database.output).properties.hostName
  redis_port        = jsondecode(azapi_resource.redis_database.output).properties.port
  redis_primary_key = jsondecode(data.azapi_resource_action.redis_keys.output).primaryKey

  redis_connection_string = "${local.redis_hostname}:${local.redis_port},password=${local.redis_primary_key},ssl=true"
}
