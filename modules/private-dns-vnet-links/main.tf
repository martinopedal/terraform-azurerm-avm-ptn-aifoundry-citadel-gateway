locals {
  zone_id_parts = {
    for key, id in var.private_dns_zone_ids : key => split("/", id)
  }

  zones = {
    for key, parts in local.zone_id_parts : key => {
      resource_group_name = parts[index(parts, "resourceGroups") + 1]
      name                = parts[length(parts) - 1]
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.zones

  name                  = "${var.name_prefix}-${each.key}"
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = var.registration_enabled
  tags                  = var.tags
}
