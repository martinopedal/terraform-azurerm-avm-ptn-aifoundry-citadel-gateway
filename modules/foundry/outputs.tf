output "foundry_ids" {
  value = { for k, v in azapi_resource.foundry : k => v.id }
}

output "foundry_endpoints" {
  value = { for k, v in azapi_resource.foundry : k => v.output.properties.endpoint }
}

output "foundry_principal_ids" {
  value = { for k, v in azapi_resource.foundry : k => v.identity[0].principal_id }
}
