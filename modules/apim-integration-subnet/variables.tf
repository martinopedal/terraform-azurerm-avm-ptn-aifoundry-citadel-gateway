variable "name" {
  type        = string
  description = "Name of the APIM Standard v2 outbound integration subnet."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network."
}

variable "virtual_network_name" {
  type        = string
  description = "Virtual network name."
}

variable "address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the delegated subnet."
}

variable "network_security_group_id" {
  type        = string
  description = "Optional NSG resource ID to associate with the subnet. If not provided, a default NSG will be created."
  default     = null
}

variable "create_nsg" {
  type        = bool
  description = "Create a default NSG if network_security_group_id is not provided."
  default     = true
}

variable "nsg_name" {
  type        = string
  description = "Name for the NSG if created. Required if create_nsg is true and network_security_group_id is null."
  default     = null
}

variable "route_table_id" {
  type        = string
  description = "Optional route table resource ID to associate with the subnet."
  default     = null
}
