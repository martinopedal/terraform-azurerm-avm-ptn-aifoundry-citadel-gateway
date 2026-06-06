output "link_ids" {
  description = "Private DNS VNet link resource IDs by input key."
  value       = { for key, link in azurerm_private_dns_zone_virtual_network_link.this : key => link.id }
}
