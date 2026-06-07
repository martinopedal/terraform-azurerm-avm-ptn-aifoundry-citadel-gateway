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

resource "azurerm_subnet" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  delegation {
    name = "Microsoft.Web-serverFarms"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Associate BYO NSG if provided
resource "azurerm_subnet_network_security_group_association" "byo" {
  count = var.network_security_group_id != null ? 1 : 0

  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = var.network_security_group_id
}

# Associate created NSG if creating one
resource "azurerm_subnet_network_security_group_association" "created" {
  count = var.create_nsg && var.network_security_group_id == null ? 1 : 0

  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.default[0].id

  depends_on = [azurerm_network_security_group.default]
}

resource "azurerm_subnet_route_table_association" "this" {
  count = var.route_table_id != null ? 1 : 0

  subnet_id      = azurerm_subnet.this.id
  route_table_id = var.route_table_id
}
