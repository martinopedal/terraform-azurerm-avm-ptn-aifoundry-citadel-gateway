variable "cosmos_account_name" {
  type = string
}

variable "cosmos_capacity_mode" {
  type    = string
  default = "serverless"
}

variable "cosmos_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "database_name" {
  type    = string
  default = "ai-usage-db"
}

variable "container_name_usage" {
  type    = string
  default = "ai-usage-container"
}

variable "container_name_pii" {
  type    = string
  default = "pii-usage-container"
}

variable "container_name_llm" {
  type    = string
  default = "llm-usage-container"
}

variable "throughput" {
  type    = number
  default = 400
}

variable "cosmos_private_endpoint_name" {
  type = string
}

variable "cosmos_private_dns_zone_id" {
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
