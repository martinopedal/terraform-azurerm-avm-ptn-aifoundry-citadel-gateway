output "subnet_id" {
  description = "Resource ID of the APIM integration subnet."
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "Name of the APIM integration subnet."
  value       = azurerm_subnet.this.name
}
