variable "function_app_name" {
  type = string
}

variable "service_plan_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_access_key" {
  type      = string
  sensitive = true
}

variable "vnet_integration_enabled" {
  type    = bool
  default = true
}

variable "function_subnet_id" {
  type    = string
  default = ""
}

variable "app_insights_connection_string" {
  type      = string
  sensitive = true
}

variable "app_insights_key" {
  type      = string
  sensitive = true
}

variable "app_settings" {
  type    = map(string)
  default = {}
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
