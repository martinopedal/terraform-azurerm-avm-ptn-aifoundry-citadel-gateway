# ============================================================================
# NETWORKING MODULE - Variables
# ============================================================================

variable "create_new_vnet" {
  type        = bool
  description = "Create a new VNet. If false, existing VNet resources are referenced."
}

variable "vnet_name" {
  type        = string
  description = "Name of the VNet (new or existing)."
}

variable "vnet_address_prefix" {
  type        = string
  description = "Address prefix for the new VNet. Only used if create_new_vnet = true."
}

variable "location" {
  type        = string
  description = "Azure region for new resources."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "existing_vnet_resource_group_name" {
  type        = string
  description = "Resource group containing existing VNet. Only used if create_new_vnet = false."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}

# Subnet configuration
variable "apim_subnet_name" {
  type        = string
  description = "APIM subnet name."
}

variable "apim_subnet_prefix" {
  type        = string
  description = "APIM subnet address prefix."
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Private endpoint subnet name."
}

variable "private_endpoint_subnet_prefix" {
  type        = string
  description = "Private endpoint subnet address prefix."
}

variable "function_app_subnet_name" {
  type        = string
  description = "Function app subnet name."
}

variable "function_app_subnet_prefix" {
  type        = string
  description = "Function app subnet address prefix."
}

variable "enable_agent_subnet" {
  type        = bool
  description = "Enable agent subnet for AI Foundry network injection."
}

variable "agent_subnet_name" {
  type        = string
  description = "Agent subnet name (for AI Foundry network injection)."
}

variable "agent_subnet_prefix" {
  type        = string
  description = "Agent subnet address prefix."
}

# NSG configuration
variable "apim_nsg_name" {
  type        = string
  description = "APIM NSG name."
}

variable "private_endpoint_nsg_name" {
  type        = string
  description = "Private endpoint NSG name."
}

variable "function_app_nsg_name" {
  type        = string
  description = "Function app NSG name."
}

variable "agent_subnet_nsg_name" {
  type        = string
  description = "Agent subnet NSG name."
}

# Route table
variable "apim_route_table_name" {
  type        = string
  description = "APIM route table name."
}

# APIM SKU flag
variable "is_apim_v2_sku" {
  type        = bool
  description = "Is APIM using v2 SKU (StandardV2 or PremiumV2)."
}

# Private DNS zones
variable "private_dns_zone_names" {
  type        = list(string)
  description = "List of private DNS zone names to create (only if create_new_vnet = true)."
}

variable "enable_telemetry" {
  type        = bool
  description = "Enable AVM telemetry."
  default     = true
}
