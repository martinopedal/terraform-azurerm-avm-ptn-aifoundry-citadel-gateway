variable "logic_app_name" {
  type = string
}

variable "cosmos_account_name" {
  type = string
}

variable "cosmos_account_id" {
  type = string
}

variable "eventhub_namespace_id" {
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
