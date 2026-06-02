variable "name" {
  type        = string
  description = "Name of the Azure Managed Redis Enterprise resource"
}

variable "location" {
  type        = string
  description = "Azure region for the Redis resource"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "resource_group_id" {
  type        = string
  description = "Resource ID of the resource group"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to Redis and related resources"
}

variable "sku_name" {
  type        = string
  default     = "Balanced_B1"
  description = "Redis Enterprise SKU name. Balanced_B1 is the smallest cost-optimized tier (~$200/mo for semantic caching)."
  validation {
    condition = contains([
      "Enterprise_E1", "Enterprise_E5", "Enterprise_E10", "Enterprise_E20", "Enterprise_E50", "Enterprise_E100", "Enterprise_E200", "Enterprise_E400",
      "EnterpriseFlash_F300", "EnterpriseFlash_F700", "EnterpriseFlash_F1500",
      "Balanced_B0", "Balanced_B1", "Balanced_B3", "Balanced_B5", "Balanced_B10", "Balanced_B20", "Balanced_B50", "Balanced_B100", "Balanced_B150", "Balanced_B250", "Balanced_B350", "Balanced_B500", "Balanced_B700", "Balanced_B1000",
      "MemoryOptimized_M10", "MemoryOptimized_M20", "MemoryOptimized_M50", "MemoryOptimized_M100", "MemoryOptimized_M150", "MemoryOptimized_M250", "MemoryOptimized_M350", "MemoryOptimized_M500", "MemoryOptimized_M700", "MemoryOptimized_M1000", "MemoryOptimized_M1500", "MemoryOptimized_M2000",
      "ComputeOptimized_X3", "ComputeOptimized_X5", "ComputeOptimized_X10", "ComputeOptimized_X20", "ComputeOptimized_X50", "ComputeOptimized_X100", "ComputeOptimized_X150", "ComputeOptimized_X250", "ComputeOptimized_X350", "ComputeOptimized_X500", "ComputeOptimized_X700",
      "FlashOptimized_A250", "FlashOptimized_A500", "FlashOptimized_A700", "FlashOptimized_A1000", "FlashOptimized_A1500", "FlashOptimized_A2000", "FlashOptimized_A4500"
    ], var.sku_name)
    error_message = "Invalid SKU name. Must be a valid Microsoft.Cache/redisEnterprise SKU."
  }
}

variable "sku_capacity" {
  type        = number
  default     = 2
  description = "Redis Enterprise cluster capacity. Only used for Enterprise_* and EnterpriseFlash_* SKUs. Valid values are (2, 4, 6, ...) for Enterprise SKUs and (3, 9, 15, ...) for EnterpriseFlash SKUs."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version for Redis connections"
}

variable "public_network_access" {
  type        = string
  default     = "Disabled"
  description = "Whether public endpoint access is allowed for this Redis. If Disabled, private endpoints are the exclusive access method."
  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "public_network_access must be either 'Enabled' or 'Disabled'."
  }
}

variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Whether to create a private endpoint for Redis"
}

variable "private_endpoint_name" {
  type        = string
  description = "Name of the Redis private endpoint"
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the Redis private endpoint"
}

variable "redis_private_dns_zone_id" {
  type        = string
  default     = ""
  description = "Private DNS zone resource ID for Redis (privatelink.redisenterprise.cache.azure.net or privatelink.redis.azure.net)"
}
