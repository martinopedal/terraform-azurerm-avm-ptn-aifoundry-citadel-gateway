# ============================================================================
# NETWORKING MODULE - Main
# ============================================================================

# Create new VNet using AVM module
module "vnet" {
  count   = var.create_new_vnet ? 1 : 0
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.7.0"

  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_prefix]
  
  tags                = var.tags
  enable_telemetry    = var.enable_telemetry

  # Subnets will be created separately for better control over NSG/delegation
  subnets = {}
}

# Reference existing VNet
data "azurerm_virtual_network" "existing" {
  count               = var.create_new_vnet ? 0 : 1
  name                = var.vnet_name
  resource_group_name = var.existing_vnet_resource_group_name
}

# Reference existing subnets (BYO scenario)
data "azurerm_subnet" "apim_existing" {
  count                = var.create_new_vnet ? 0 : 1
  name                 = var.apim_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
}

data "azurerm_subnet" "private_endpoint_existing" {
  count                = var.create_new_vnet ? 0 : 1
  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
}

data "azurerm_subnet" "function_app_existing" {
  count                = var.create_new_vnet ? 0 : 1
  name                 = var.function_app_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
}

data "azurerm_subnet" "agent_existing" {
  count                = var.create_new_vnet || !var.enable_agent_subnet ? 0 : 1
  name                 = var.agent_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
}

# NSGs (only for new VNet)
# cost: NSGs are free
resource "azurerm_network_security_group" "apim" {
  count               = var.create_new_vnet ? 1 : 0
  name                = var.apim_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # APIM-specific rules from bicep
  security_rule {
    name                       = "AllowPublicAccess"
    priority                   = 3000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAPIMManagement"
    priority                   = 3010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAPIMLoadBalancer"
    priority                   = 3020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "6390"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureTrafficManager"
    priority                   = 3030
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureTrafficManager"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowStorage"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Storage"
  }

  security_rule {
    name                       = "AllowSQL"
    priority                   = 3010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Sql"
  }

  security_rule {
    name                       = "AllowKeyVault"
    priority                   = 3020
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureKeyVault"
  }

  security_rule {
    name                       = "AllowEventHub"
    priority                   = 3030
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "5671", "5672"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "EventHub"
  }

  security_rule {
    name                       = "AllowAzureMonitor"
    priority                   = 3040
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "1886"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureMonitor"
  }
}

resource "azurerm_network_security_group" "private_endpoint" {
  count               = var.create_new_vnet ? 1 : 0
  name                = var.private_endpoint_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "function_app" {
  count               = var.create_new_vnet ? 1 : 0
  name                = var.function_app_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "agent" {
  count               = var.create_new_vnet && var.enable_agent_subnet ? 1 : 0
  name                = var.agent_subnet_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Route table for APIM subnet (only for new VNet)
# cost: Route tables are free
resource "azurerm_route_table" "apim" {
  count                = var.create_new_vnet ? 1 : 0
  name                 = var.apim_route_table_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  tags                 = var.tags
}

# Subnets (only for new VNet)
resource "azurerm_subnet" "apim" {
  count                = var.create_new_vnet ? 1 : 0
  name                 = var.apim_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.vnet[0].name
  address_prefixes     = [var.apim_subnet_prefix]

  # Service endpoints for APIM
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.EventHub",
    "Microsoft.KeyVault"
  ]
}

resource "azurerm_subnet_network_security_group_association" "apim" {
  count                     = var.create_new_vnet ? 1 : 0
  subnet_id                 = azurerm_subnet.apim[0].id
  network_security_group_id = azurerm_network_security_group.apim[0].id
}

resource "azurerm_subnet_route_table_association" "apim" {
  count          = var.create_new_vnet ? 1 : 0
  subnet_id      = azurerm_subnet.apim[0].id
  route_table_id = azurerm_route_table.apim[0].id
}

resource "azurerm_subnet" "private_endpoint" {
  count                = var.create_new_vnet ? 1 : 0
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.vnet[0].name
  address_prefixes     = [var.private_endpoint_subnet_prefix]
}

resource "azurerm_subnet_network_security_group_association" "private_endpoint" {
  count                     = var.create_new_vnet ? 1 : 0
  subnet_id                 = azurerm_subnet.private_endpoint[0].id
  network_security_group_id = azurerm_network_security_group.private_endpoint[0].id
}

resource "azurerm_subnet" "function_app" {
  count                = var.create_new_vnet ? 1 : 0
  name                 = var.function_app_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.vnet[0].name
  address_prefixes     = [var.function_app_subnet_prefix]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "function_app" {
  count                     = var.create_new_vnet ? 1 : 0
  subnet_id                 = azurerm_subnet.function_app[0].id
  network_security_group_id = azurerm_network_security_group.function_app[0].id
}

# Agent subnet (for AI Foundry network injection)
resource "azurerm_subnet" "agent" {
  count                = var.create_new_vnet && var.enable_agent_subnet ? 1 : 0
  name                 = var.agent_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.vnet[0].name
  address_prefixes     = [var.agent_subnet_prefix]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "agent" {
  count                     = var.create_new_vnet && var.enable_agent_subnet ? 1 : 0
  subnet_id                 = azurerm_subnet.agent[0].id
  network_security_group_id = azurerm_network_security_group.agent[0].id
}

# Private DNS zones (only for new VNet)
resource "azurerm_private_dns_zone" "this" {
  for_each            = var.create_new_vnet ? toset(var.private_dns_zone_names) : []
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.create_new_vnet ? toset(var.private_dns_zone_names) : []
  name                  = "${var.vnet_name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = module.vnet[0].resource_id
  tags                  = var.tags
}
