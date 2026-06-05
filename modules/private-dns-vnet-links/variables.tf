variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Map of Private DNS zone resource IDs to link to the VNet."
}

variable "virtual_network_id" {
  type        = string
  description = "Virtual network resource ID to link."
}

variable "name_prefix" {
  type        = string
  description = "Prefix for generated VNet link names."
}

variable "registration_enabled" {
  type        = bool
  description = "Whether auto-registration is enabled on the VNet links."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Private DNS VNet links."
  default     = {}
}
