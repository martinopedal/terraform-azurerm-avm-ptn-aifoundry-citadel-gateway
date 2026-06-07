output "subnet_id" {
  description = "Resource ID of the delegated subnet."
  value       = azapi_update_resource.this.id
}
