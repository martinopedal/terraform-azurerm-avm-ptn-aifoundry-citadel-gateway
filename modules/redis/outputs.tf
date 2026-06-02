output "redis_enterprise_id" {
  value       = azapi_resource.redis_enterprise.id
  description = "Resource ID of the Redis Enterprise cluster"
}

output "redis_database_id" {
  value       = azapi_resource.redis_database.id
  description = "Resource ID of the Redis database"
}

output "redis_connection_string" {
  value       = local.redis_connection_string
  description = "Redis connection string (hostName:port,password=key,ssl=true) for APIM semantic cache named value"
  sensitive   = true
}

output "redis_hostname" {
  value       = local.redis_hostname
  description = "Redis hostname"
}

output "redis_port" {
  value       = local.redis_port
  description = "Redis port (10000 for Managed Redis with RediSearch)"
}

output "redis_primary_key" {
  value       = local.redis_primary_key
  description = "Redis primary access key"
  sensitive   = true
}
