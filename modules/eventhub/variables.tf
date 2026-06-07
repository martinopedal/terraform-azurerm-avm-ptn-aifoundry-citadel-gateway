variable "namespace_name" {
  type = string
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "capacity" {
  type    = number
  default = 1
}

variable "auto_inflate_enabled" {
  type    = bool
  default = false
}

variable "maximum_throughput_units" {
  type    = number
  default = 1
}

variable "zone_redundant" {
  type    = bool
  default = false
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "disable_local_auth" {
  type    = bool
  default = false
}

variable "usage_hub_name" {
  type    = string
  default = "usage"
}

variable "usage_partition_count" {
  type    = number
  default = 2
}

variable "usage_message_retention" {
  type    = number
  default = 1
}

variable "pii_hub_name" {
  type    = string
  default = "pii"
}

variable "pii_partition_count" {
  type    = number
  default = 2
}

variable "pii_message_retention" {
  type    = number
  default = 1
}

variable "enable_private_endpoints" {
  type    = bool
  default = true
}

variable "private_endpoint_name" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "eventhub_private_dns_zone_id" {
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

variable "enable_telemetry" {
  type    = bool
  default = true
}
