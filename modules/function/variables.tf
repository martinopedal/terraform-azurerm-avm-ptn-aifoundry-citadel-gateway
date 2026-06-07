variable "function_app_name" {
  type = string
}

variable "service_plan_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_id" {
  type        = string
  description = "Resource ID of the storage account used for Function host storage. Required when storage_uses_managed_identity is true and host storage RBAC should be created."
  default     = ""
}

variable "storage_account_access_key" {
  type      = string
  sensitive = true
  default   = null
}

variable "storage_uses_managed_identity" {
  type        = bool
  description = "Use the Function App managed identity for AzureWebJobsStorage instead of a storage access key."
  default     = false
}

variable "host_storage_role_names" {
  type        = set(string)
  description = "Storage data-plane roles assigned to the Function App managed identity when storage_uses_managed_identity is true."
  default = [
    "Storage Blob Data Owner",
    "Storage Queue Data Contributor",
    "Storage Table Data Contributor"
  ]
}

variable "content_share_force_disabled" {
  type        = bool
  description = "Suppress Azure Files content-share settings. Use with identity-based host storage on Dedicated plans."
  default     = false
}

variable "service_plan_sku_name" {
  type        = string
  description = "App Service plan SKU for the Linux Function App."
  default     = "Y1"
}

variable "always_on" {
  type        = bool
  description = "Enable Always On for Dedicated App Service plan SKUs."
  default     = false
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
