output "subnet_id" {
  description = "Resource ID of the APIM integration subnet."
  value       = azapi_resource.subnet.id
}

output "subnet_name" {
  description = "Name of the APIM integration subnet."
  value       = azapi_resource.subnet.name
}
