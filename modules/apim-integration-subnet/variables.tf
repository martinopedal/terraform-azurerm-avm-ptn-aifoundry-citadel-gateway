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
  description = "Optional NSG resource ID to associate with the subnet."
  default     = null
}

variable "route_table_id" {
  type        = string
  description = "Optional route table resource ID to associate with the subnet."
  default     = null
}
