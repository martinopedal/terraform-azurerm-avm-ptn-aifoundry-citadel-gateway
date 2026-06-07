variable "subnet_id" {
  type        = string
  description = "Resource ID of the existing subnet to delegate."
}

variable "delegation_name" {
  type        = string
  description = "Name of the subnet delegation block."
  default     = "delegation"
}

variable "service_delegation_name" {
  type        = string
  description = "Azure service delegation name."
  default     = "Microsoft.Web/serverFarms"
}

variable "actions" {
  type        = list(string)
  description = "Delegation actions required by the Azure service."
  default     = ["Microsoft.Network/virtualNetworks/subnets/action"]
}
