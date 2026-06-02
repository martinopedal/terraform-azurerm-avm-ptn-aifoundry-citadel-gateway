variable "storage_account_name" {
  type = string
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "enable_private_endpoints" {
  type    = bool
  default = true
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "storage_blob_private_dns_zone_id" {
  type    = string
  default = ""
}

variable "storage_file_private_dns_zone_id" {
  type    = string
  default = ""
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
