variable "apim_identity_name" {
  type        = string
  description = "APIM managed identity name"
}

variable "usage_identity_name" {
  type        = string
  description = "Usage Logic App managed identity name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "resource_group_id" {
  type        = string
  description = "Resource group ID for RBAC scope"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}
