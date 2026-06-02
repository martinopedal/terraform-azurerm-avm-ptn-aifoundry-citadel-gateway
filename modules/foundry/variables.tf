variable "foundry_instances" {
  type = list(object({
    name                   = string
    location               = string
    custom_sub_domain_name = string
  }))
}

variable "foundry_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "disable_local_auth" {
  type    = bool
  default = false
}

variable "foundry_private_dns_zone_ids" {
  type    = list(string)
  default = []
}

variable "enable_private_endpoints" {
  type    = bool
  default = true
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "apim_principal_id" {
  type = string
}

variable "resource_token" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
