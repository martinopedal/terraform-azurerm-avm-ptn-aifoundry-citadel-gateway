# Create a default NSG if none provided
resource "azurerm_network_security_group" "default" {
  count               = var.create_nsg && var.network_security_group_id == null ? 1 : 0
  name                = var.nsg_name != null ? var.nsg_name : "${var.name}-nsg"
  location            = data.azurerm_virtual_network.this.location
  resource_group_name = var.resource_group_name

  # Minimal rules for APIM Standard v2 outbound integration
  security_rule {
    name                       = "AllowVnetOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Internet"
  }
}

data "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

locals {
  effective_network_security_group_id = var.network_security_group_id != null ? var.network_security_group_id : (
    var.create_nsg ? azurerm_network_security_group.default[0].id : null
  )

  subnet_properties = merge(
    {
      addressPrefixes = var.address_prefixes
      delegations = [
        {
          name = "Microsoft.Web-serverFarms"
          properties = {
            serviceName = "Microsoft.Web/serverFarms"
            actions     = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ]
    },
    local.effective_network_security_group_id != null ? {
      networkSecurityGroup = {
        id = local.effective_network_security_group_id
      }
    } : {},
    var.route_table_id != null ? {
      routeTable = {
        id = var.route_table_id
      }
    } : {}
  )
}

resource "azapi_resource" "subnet" {
  type                      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  name                      = var.name
  parent_id                 = data.azurerm_virtual_network.this.id
  schema_validation_enabled = false
  body = {
    properties = local.subnet_properties
  }
}
