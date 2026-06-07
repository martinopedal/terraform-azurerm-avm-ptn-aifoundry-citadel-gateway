variable "log_analytics_name" {
  type        = string
  description = "Log Analytics workspace name"
}

variable "use_existing_log_analytics" {
  type        = bool
  description = "Use existing Log Analytics workspace"
}

variable "existing_log_analytics_name" {
  type        = string
  description = "Existing Log Analytics workspace name"
  default     = ""
}

variable "existing_log_analytics_rg" {
  type        = string
  description = "Existing Log Analytics workspace resource group"
  default     = ""
}

variable "log_analytics_retention_days" {
  type        = number
  description = "Log Analytics retention in days (30 = free)"
  default     = 30
}

variable "apim_app_insights_name" {
  type        = string
  description = "APIM Application Insights name"
}

variable "function_app_insights_name" {
  type        = string
  description = "Function Application Insights name"
}

variable "foundry_app_insights_name" {
  type        = string
  description = "Foundry Application Insights name"
}

variable "apim_dashboard_name" {
  type        = string
  description = "APIM dashboard name"
}

variable "function_dashboard_name" {
  type        = string
  description = "Function dashboard name"
}

variable "foundry_dashboard_name" {
  type        = string
  description = "Foundry dashboard name"
}

variable "create_dashboards" {
  type        = bool
  description = "Create portal dashboards"
  default     = false
}

variable "use_azure_monitor_private_link_scope" {
  type        = bool
  description = "Use Azure Monitor Private Link Scope"
  default     = false
}

variable "enable_private_endpoints" {
  type        = bool
  description = "Enable private endpoints"
  default     = true
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Private endpoint subnet ID"
}

variable "monitor_private_dns_zone_id" {
  type        = string
  description = "Monitor private DNS zone ID (for private endpoint)"
  default     = ""
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}

variable "enable_telemetry" {
  type        = bool
  description = "Enable AVM telemetry"
  default     = true
}
