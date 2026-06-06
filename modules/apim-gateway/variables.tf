variable "apim_service_name" {
  description = "Name of the API Management service"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing APIM"
  type        = string
}

variable "apim_managed_identity_client_id" {
  description = "Client ID of the user-assigned managed identity for APIM backend authentication"
  type        = string
  default     = ""
}

variable "llm_backend_config" {
  description = "Configuration array for LLM backends. Each backend represents an AI service endpoint with supported models."
  type = list(object({
    backend_id   = string
    backend_type = string # "ai-foundry", "azure-openai", "external"
    endpoint     = string
    auth_scheme  = string # "managedIdentity", "apiKey", "none"
    priority     = optional(number, 1)
    weight       = optional(number, 100)
    supported_models = list(object({
      name            = string
      sku             = optional(string, "Standard")
      capacity        = optional(number, 100)
      model_format    = optional(string, "OpenAI")
      model_version   = optional(string, "1")
      retirement_date = optional(string)
    }))
  }))
  default = []
}

variable "configure_circuit_breaker" {
  description = "Whether to configure circuit breaker for backends (resilience feature)"
  type        = bool
  default     = true
}

variable "inference_api_name" {
  description = "Name of the Universal LLM API in APIM"
  type        = string
  default     = "inference-api"
}

variable "inference_api_description" {
  description = "Description of the Universal LLM API"
  type        = string
  default     = "Inferencing API for language models"
}

variable "inference_api_display_name" {
  description = "Display name of the Universal LLM API"
  type        = string
  default     = "Inference API"
}

variable "inference_api_path" {
  description = "Base path for the inference API in APIM (endpoint path appended automatically)"
  type        = string
  default     = "inference"
}

variable "inference_api_type" {
  description = "The inference API type - determines endpoint path and OpenAPI spec"
  type        = string
  default     = "AzureOpenAI"
  validation {
    condition     = contains(["AzureOpenAI", "AzureAI", "OpenAI", "OpenAIV1"], var.inference_api_type)
    error_message = "inference_api_type must be one of: AzureOpenAI, AzureAI, OpenAI, OpenAIV1"
  }
}

variable "allow_subscription_key" {
  description = "Allow the use of subscription key for the inference API (set to false for JWT-only auth)"
  type        = bool
  default     = true
}

variable "apim_logger_id" {
  description = "Resource ID of the APIM logger for Azure Monitor diagnostics (leave empty to disable)"
  type        = string
  default     = ""
}

variable "enable_azure_monitor_diagnostics" {
  description = "Create Azure Monitor API diagnostics. Use this when apim_logger_id is supplied from a resource whose ID is unknown until apply."
  type        = bool
  default     = false
}

variable "app_insights_id" {
  description = "Resource ID of Application Insights for diagnostics (leave empty to disable)"
  type        = string
  default     = ""
}

variable "app_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_monitor_log_settings" {
  description = "Azure Monitor diagnostic log settings for the inference API"
  type = object({
    frontend = object({
      request = object({
        headers = list(string)
        body    = object({ bytes = number })
      })
      response = object({
        headers = list(string)
        body    = object({ bytes = number })
      })
    })
    backend = object({
      request = object({
        headers = list(string)
        body    = object({ bytes = number })
      })
      response = object({
        headers = list(string)
        body    = object({ bytes = number })
      })
    })
    large_language_model = object({
      logs = string
      requests = object({
        messages          = string
        max_size_in_bytes = number
      })
      responses = object({
        messages          = string
        max_size_in_bytes = number
      })
    })
  })
  default = {
    frontend = {
      request  = { headers = [], body = { bytes = 0 } }
      response = { headers = [], body = { bytes = 0 } }
    }
    backend = {
      request  = { headers = [], body = { bytes = 0 } }
      response = { headers = [], body = { bytes = 0 } }
    }
    large_language_model = {
      logs      = "enabled"
      requests  = { messages = "all", max_size_in_bytes = 262144 }
      responses = { messages = "all", max_size_in_bytes = 262144 }
    }
  }
}

variable "app_insights_log_settings" {
  description = "Application Insights diagnostic log settings"
  type = object({
    headers = list(string)
    body    = object({ bytes = number })
  })
  default = {
    headers = ["Content-type", "User-agent", "x-ms-region", "x-ratelimit-remaining-tokens", "x-ratelimit-remaining-requests"]
    body    = { bytes = 0 }
  }
}
