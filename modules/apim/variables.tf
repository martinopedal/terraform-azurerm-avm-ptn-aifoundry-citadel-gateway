variable "apim_name" {
  type = string
}

variable "apim_sku" {
  type = string
}

variable "apim_publisher_name" {
  type = string
}

variable "apim_publisher_email" {
  type = string
}

variable "apim_network_type" {
  type    = string
  default = "External"
}

variable "apim_subnet_id" {
  type = string
}

variable "apim_managed_identity_id" {
  type = string
}

variable "is_apim_v2_sku" {
  type = bool
}

variable "enable_private_endpoints" {
  type    = bool
  default = true
}

variable "apim_private_endpoint_name" {
  type = string
}

variable "apim_private_dns_zone_id" {
  type    = string
  default = ""
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "event_hub_name" {
  type = string
}

variable "event_hub_connection_string" {
  type      = string
  sensitive = true
}

variable "app_insights_instrumentation_key" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}

variable "audience" {
  type    = string
  default = "https://cognitiveservices.azure.com/.default"
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
