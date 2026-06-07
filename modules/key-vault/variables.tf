variable "key_vault_name" {
  type = string
}

variable "key_vault_sku_name" {
  type    = string
  default = "standard"
}

variable "key_vault_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "key_vault_private_endpoint_name" {
  type = string
}

variable "key_vault_private_dns_zone_id" {
  type    = string
  default = ""
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

variable "entra_client_secret" {
  type      = string
  default   = ""
  sensitive = true
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_telemetry" {
  type    = bool
  default = true
}
