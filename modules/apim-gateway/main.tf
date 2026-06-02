#####################################################
# APIM AI Gateway Module
# Implements the Universal LLM API, backends, backend pools,
# and policy fragments for AI model routing and governance.
#
# This module uses AzAPI for APIM resources (APIs, backends,
# policy fragments) to match the Bicep reference implementation.
#####################################################

terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

#####################################################
# DATA SOURCES
#####################################################

# Get APIM service details
data "azurerm_api_management" "apim" {
  name                = var.apim_service_name
  resource_group_name = var.resource_group_name
}

#####################################################
# LLM BACKENDS
# Individual backends for each AI service endpoint
#####################################################

resource "azapi_resource" "llm_backend" {
  for_each = { for b in var.llm_backend_config : b.backend_id => b }

  type      = "Microsoft.ApiManagement/service/backends@2024-06-01-preview"
  name      = each.value.backend_id
  parent_id = data.azurerm_api_management.apim.id

  # Disable schema validation - managedIdentity credentials are valid at runtime
  # but not recognized by provider schema (similar to Bicep BCP037 suppression)
  schema_validation_enabled = false

  body = {
    properties = {
      description = "LLM Backend: ${each.value.backend_type} - ${each.value.backend_id} - Supports models: ${join(", ", [for m in each.value.supported_models : m.name])}"
      url         = each.value.endpoint
      protocol    = "http"

      # Circuit breaker for resilience (only if enabled)
      circuitBreaker = var.configure_circuit_breaker ? {
        rules = [
          {
            failureCondition = {
              count        = 3
              errorReasons = ["Server errors"]
              interval     = "PT5M"
              statusCodeRanges = [
                { min = 429, max = 429 },
                { min = 500, max = 503 }
              ]
            }
            name             = "${each.value.backend_id}-breaker-rule"
            tripDuration     = "PT1M"
            acceptRetryAfter = true
          }
        ]
      } : null

      # Managed identity auth for Azure backends
      credentials = {
        managedIdentity = each.value.auth_scheme == "managedIdentity" ? {
          clientId = var.apim_managed_identity_client_id
          resource = "https://cognitiveservices.azure.com"
        } : null
        header = each.value.auth_scheme == "managedIdentity" ? {
          "x-ms-client-id" = [var.apim_managed_identity_client_id]
        } : {}
      }

      # TLS validation
      tls = {
        validateCertificateChain = true
        validateCertificateName  = true
      }
    }
  }

  depends_on = []
}

#####################################################
# BACKEND POOLS
# Group backends by supported models for load balancing
#####################################################

locals {
  # Normalize backend details - extract model names from supported_models
  normalized_backends = [
    for backend_id, backend in azapi_resource.llm_backend : {
      backend_id   = backend.name
      backend_type = var.llm_backend_config[index([for b in var.llm_backend_config : b.backend_id], backend_id)].backend_type
      resource_id  = backend.id
      priority     = try(var.llm_backend_config[index([for b in var.llm_backend_config : b.backend_id], backend_id)].priority, 1)
      weight       = try(var.llm_backend_config[index([for b in var.llm_backend_config : b.backend_id], backend_id)].weight, 100)
      model_names  = [for m in var.llm_backend_config[index([for b in var.llm_backend_config : b.backend_id], backend_id)].supported_models : m.name]
    }
  ]

  # Build map of model -> list of backends that support it
  model_to_backends_raw = flatten([
    for backend in local.normalized_backends : [
      for model in backend.model_names : {
        model        = model
        backend_id   = backend.backend_id
        backend_type = backend.backend_type
        resource_id  = backend.resource_id
        priority     = backend.priority
        weight       = backend.weight
      }
    ]
  ])

  model_to_backends = {
    for model in distinct([for item in local.model_to_backends_raw : item.model]) :
    model => [for item in local.model_to_backends_raw : item if item.model == model]
  }

  # Create pools only for models with multiple backends
  pool_configs = {
    for model, backends in local.model_to_backends :
    model => {
      model_name = model
      pool_name  = "${replace(model, ".", "")}-backend-pool"
      backends   = backends
    } if length(backends) > 1
  }
}

resource "azapi_resource" "backend_pool" {
  for_each = local.pool_configs

  type      = "Microsoft.ApiManagement/service/backends@2024-06-01-preview"
  name      = each.value.pool_name
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Backend pool for model: ${each.value.model_name}"
      type        = "Pool"
      pool = {
        services = [
          for backend in each.value.backends : {
            id       = "/backends/${backend.backend_id}"
            priority = backend.priority
            weight   = backend.weight
          }
        ]
      }
    }
  }

  depends_on = [azapi_resource.llm_backend]
}

#####################################################
# POLICY FRAGMENTS
# Reusable policy blocks for routing, auth, and usage
#####################################################

# AWS named values (required by set-backend-authorization fragment, safe defaults)
resource "azapi_resource" "aws_access_key" {
  type      = "Microsoft.ApiManagement/service/namedValues@2024-06-01-preview"
  name      = "aws-access-key"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      displayName = "aws-access-key"
      value       = "NOT_CONFIGURED"
      secret      = true
    }
  }
}

resource "azapi_resource" "aws_secret_key" {
  type      = "Microsoft.ApiManagement/service/namedValues@2024-06-01-preview"
  name      = "aws-secret-key"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      displayName = "aws-secret-key"
      value       = "NOT_CONFIGURED"
      secret      = true
    }
  }
}

resource "azapi_resource" "aws_region" {
  type      = "Microsoft.ApiManagement/service/namedValues@2024-06-01-preview"
  name      = "aws-region"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      displayName = "aws-region"
      value       = "NOT_CONFIGURED"
      secret      = false
    }
  }
}

# Generate backend pools code for set-backend-pools fragment
locals {
  # Build backendPoolsCode for injection into policy fragment
  all_pools = concat(
    [for pool in azapi_resource.backend_pool : {
      poolName        = pool.name
      poolType        = try(local.pool_configs[pool.name].backends[0].backend_type, "mixed")
      supportedModels = [local.pool_configs[pool.name].model_name]
    }],
    # Direct backends (single-backend models)
    [for model, backends in local.model_to_backends : {
      poolName        = backends[0].backend_id
      poolType        = backends[0].backend_type
      supportedModels = [model]
    } if length(backends) == 1]
  )

  backend_pools_code = join("\n", [
    for idx, pool in local.all_pools :
    <<-EOT
      // Pool: ${pool.poolName} (Type: ${pool.poolType})
      var pool_${idx} = new JObject()
      {
          { "poolName", "${pool.poolName}" },
          { "poolType", "${pool.poolType}" },
          { "supportedModels", new JArray(${join(", ", [for m in pool.supportedModels : "\"${m}\""])}) }
      };
      backendPools.Add(pool_${idx});
    EOT
  ])

  # Generate model deployments code for get-available-models fragment
  model_deployments_code = join("\n", flatten([
    for config in var.llm_backend_config : [
      for idx, model in config.supported_models :
      <<-EOT
        // Model: ${model.name} from backend: ${config.backend_id}
        var deployment_${index(var.llm_backend_config, config)}_${idx} = new JObject()
        {
            { "id", "${config.backend_id}" },
            { "type", "${config.backend_type}" },
            { "name", "${model.name}" },
            { "sku", new JObject() { { "name", "${try(model.sku, "Standard")}" }, { "capacity", ${try(model.capacity, 100)} } } },
            { "properties", new JObject() {
                { "model", new JObject() { { "format", "${try(model.model_format, "OpenAI")}" }, { "name", "${model.name}" }, { "version", "${try(model.model_version, "1")}" } } },
                { "capabilities", new JObject() { { "chatCompletion", "true" } } },
                { "provisioningState", "Succeeded" }${try(model.retirement_date, null) != null ? ",\n                { \"retirementDate\", \"${model.retirement_date}\" }" : ""}
            }}
        };
        modelDeployments.Add(deployment_${index(var.llm_backend_config, config)}_${idx});
      EOT
    ]
  ]))
}

# Policy Fragment: Set Backend Pools
resource "azapi_resource" "frag_set_backend_pools" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "set-backend-pools"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Dynamically generated backend pool configurations for LLM routing"
      format      = "rawxml"
      value       = replace(file("${path.module}/policies/frag-set-backend-pools.xml"), "//{backendPoolsCode}", local.backend_pools_code)
    }
  }

  depends_on = [azapi_resource.backend_pool, azapi_resource.llm_backend]
}

# Policy Fragment: Set Backend Authorization
resource "azapi_resource" "frag_set_backend_authorization" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "set-backend-authorization"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Authentication and routing configuration for different LLM backend types"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-set-backend-authorization.xml")
    }
  }

  depends_on = [azapi_resource.aws_access_key, azapi_resource.aws_secret_key, azapi_resource.aws_region]
}

# Policy Fragment: Set Target Backend Pool
resource "azapi_resource" "frag_set_target_backend_pool" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "set-target-backend-pool"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Determines the target backend pool for LLM requests"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-set-target-backend-pool.xml")
    }
  }

  depends_on = [azapi_resource.frag_set_backend_pools]
}

# Policy Fragment: Set LLM Requested Model
resource "azapi_resource" "frag_set_llm_requested_model" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "set-llm-requested-model"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Extracts the requested model from deployment-id (Azure OpenAI) or request body (Inference)"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-set-llm-requested-model.xml")
    }
  }
}

# Policy Fragment: Set LLM Usage
resource "azapi_resource" "frag_set_llm_usage" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "set-llm-usage"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Collects usage metrics for LLM requests"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-set-llm-usage.xml")
    }
  }
}

# Policy Fragment: Security Handler
resource "azapi_resource" "frag_security_handler" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "security-handler"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Frontend authentication (API Key + optional JWT)"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-security-handler.xml")
    }
  }
}

# Policy Fragment: Validate Model Access
resource "azapi_resource" "frag_validate_model_access" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "validate-model-access"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Validates that the requested model is in the allowed models list for the product"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-validate-model-access.xml")
    }
  }
}

# Policy Fragment: Get Available Models
resource "azapi_resource" "frag_get_available_models" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "get-available-models"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Returns a JSON response listing all available model deployments with their capabilities"
      format      = "rawxml"
      value       = replace(file("${path.module}/policies/frag-get-available-models.xml"), "//{modelDeploymentsCode}", local.model_deployments_code)
    }
  }

  depends_on = [azapi_resource.llm_backend]
}

# Policy Fragment: Responses API ID Security (inbound)
resource "azapi_resource" "frag_responses_id_security" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "responses-id-security"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Inbound: validates response_id ownership and hydrates routing for /responses operations"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-responses-id-security.xml")
    }
  }
}

# Policy Fragment: Responses API ID Cache Store (outbound)
resource "azapi_resource" "frag_responses_id_cache_store" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "responses-id-cache-store"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Outbound: caches response_id ownership for newly created Responses API objects"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-responses-id-cache-store.xml")
    }
  }
}

# Policy Fragment: Set Response Headers
resource "azapi_resource" "frag_set_response_headers" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "set-response-headers"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Injects standard response headers for AI gateway"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-set-response-headers.xml")
    }
  }
}

# Policy Fragment: Raise Throttling Events
resource "azapi_resource" "frag_raise_throttling_events" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "raise-throttling-events"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Pushes custom metrics for throttling events to enable Azure Monitor alerts"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-raise-throttling-events.xml")
    }
  }
}

# Policy Fragment: AI Foundry Compatibility (CORS)
resource "azapi_resource" "frag_ai_foundry_compatibility" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "ai-foundry-compatibility"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "CORS configuration for AI Foundry compatibility"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-ai-foundry-compatibility.xml")
    }
  }
}

# Policy Fragment: Strip Backend Headers
resource "azapi_resource" "frag_strip_backend_headers" {
  type      = "Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview"
  name      = "strip-backend-headers"
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      description = "Removes browser/App Service/X-Forwarded-* headers before backend forwarding"
      format      = "rawxml"
      value       = file("${path.module}/policies/frag-strip-backend-headers.xml")
    }
  }
}

#####################################################
# UNIVERSAL LLM API
# OpenAI-compatible API with dynamic backend routing
#####################################################

locals {
  # Map inferenceAPIType to endpoint path and OpenAPI spec
  inference_api_type_map = {
    "AzureOpenAI" = {
      endpoint_path = "openai"
      openapi_spec  = "AIFoundryOpenAI.json"
    }
    "AzureAI" = {
      endpoint_path = "inference"
      openapi_spec  = "AIFoundryAzureAI.json"
    }
    "OpenAI" = {
      endpoint_path = "openai"
      openapi_spec  = "AIFoundryAzureAI.json"
    }
    "OpenAIV1" = {
      endpoint_path = "models"
      openapi_spec  = "AIFoundryOpenAIV1.json"
    }
  }

  api_config   = local.inference_api_type_map[var.inference_api_type]
  api_path     = "${var.inference_api_path}/${local.api_config.endpoint_path}"
  openapi_spec = jsondecode(file("${path.module}/openapi/${local.api_config.openapi_spec}"))
}

resource "azapi_resource" "universal_llm_api" {
  type      = "Microsoft.ApiManagement/service/apis@2024-06-01-preview"
  name      = var.inference_api_name
  parent_id = data.azurerm_api_management.apim.id

  body = {
    properties = {
      apiType     = "http"
      description = var.inference_api_description
      displayName = var.inference_api_display_name
      format      = "openapi+json"
      path        = local.api_path
      protocols   = ["https"]
      subscriptionKeyParameterNames = {
        header = "api-key"
        query  = "api-key"
      }
      subscriptionRequired = var.allow_subscription_key
      type                 = "http"
      value                = jsonencode(local.openapi_spec)
    }
  }

  depends_on = [
    azapi_resource.frag_set_backend_pools,
    azapi_resource.frag_set_backend_authorization,
    azapi_resource.frag_set_target_backend_pool,
    azapi_resource.frag_set_llm_requested_model,
    azapi_resource.frag_set_llm_usage,
    azapi_resource.frag_security_handler,
    azapi_resource.frag_validate_model_access,
    azapi_resource.frag_get_available_models,
    azapi_resource.frag_responses_id_security,
    azapi_resource.frag_responses_id_cache_store,
    azapi_resource.frag_set_response_headers,
    azapi_resource.frag_raise_throttling_events,
    azapi_resource.frag_ai_foundry_compatibility,
    azapi_resource.frag_strip_backend_headers
  ]
}

# API Policy (orchestration policy)
resource "azapi_resource" "universal_llm_api_policy" {
  type      = "Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview"
  name      = "policy"
  parent_id = azapi_resource.universal_llm_api.id

  body = {
    properties = {
      format = "rawxml"
      value  = file("${path.module}/policies/universal-llm-api-policy-v2.xml")
    }
  }

  depends_on = [azapi_resource.universal_llm_api]
}

# API Diagnostics (Azure Monitor)
resource "azapi_resource" "universal_llm_api_diagnostics_azmon" {
  count = var.apim_logger_id != "" ? 1 : 0

  type      = "Microsoft.ApiManagement/service/apis/diagnostics@2024-06-01-preview"
  name      = "azuremonitor"
  parent_id = azapi_resource.universal_llm_api.id

  body = {
    properties = {
      alwaysLog   = "allErrors"
      verbosity   = "verbose"
      logClientIp = true
      loggerId    = var.apim_logger_id
      sampling = {
        samplingType = "fixed"
        percentage   = 100
      }
      frontend = {
        request = {
          headers = var.azure_monitor_log_settings.frontend.request.headers
          body = {
            bytes = var.azure_monitor_log_settings.frontend.request.body.bytes
          }
        }
        response = {
          headers = var.azure_monitor_log_settings.frontend.response.headers
          body = {
            bytes = var.azure_monitor_log_settings.frontend.response.body.bytes
          }
        }
      }
      backend = {
        request = {
          headers = var.azure_monitor_log_settings.backend.request.headers
          body = {
            bytes = var.azure_monitor_log_settings.backend.request.body.bytes
          }
        }
        response = {
          headers = var.azure_monitor_log_settings.backend.response.headers
          body = {
            bytes = var.azure_monitor_log_settings.backend.response.body.bytes
          }
        }
      }
      largeLanguageModel = {
        logs = var.azure_monitor_log_settings.large_language_model.logs
        requests = {
          messages       = var.azure_monitor_log_settings.large_language_model.requests.messages
          maxSizeInBytes = var.azure_monitor_log_settings.large_language_model.requests.max_size_in_bytes
        }
        responses = {
          messages       = var.azure_monitor_log_settings.large_language_model.responses.messages
          maxSizeInBytes = var.azure_monitor_log_settings.large_language_model.responses.max_size_in_bytes
        }
      }
    }
  }

  depends_on = [azapi_resource.universal_llm_api]
}

# API Diagnostics (App Insights)
resource "azapi_resource" "universal_llm_api_diagnostics_appinsights" {
  count = var.app_insights_id != "" && var.app_insights_instrumentation_key != "" ? 1 : 0

  type      = "Microsoft.ApiManagement/service/apis/diagnostics@2024-06-01-preview"
  name      = "applicationinsights"
  parent_id = azapi_resource.universal_llm_api.id

  body = {
    properties = {
      alwaysLog               = "allErrors"
      httpCorrelationProtocol = "W3C"
      logClientIp             = true
      loggerId                = "${data.azurerm_api_management.apim.id}/loggers/appinsights-logger"
      metrics                 = true
      verbosity               = "verbose"
      sampling = {
        samplingType = "fixed"
        percentage   = 100
      }
      frontend = {
        request = {
          headers = var.app_insights_log_settings.headers
          body = {
            bytes = var.app_insights_log_settings.body.bytes
          }
        }
        response = {
          headers = var.app_insights_log_settings.headers
          body = {
            bytes = var.app_insights_log_settings.body.bytes
          }
        }
      }
      backend = {
        request = {
          headers = var.app_insights_log_settings.headers
          body = {
            bytes = var.app_insights_log_settings.body.bytes
          }
        }
        response = {
          headers = var.app_insights_log_settings.headers
          body = {
            bytes = var.app_insights_log_settings.body.bytes
          }
        }
      }
    }
  }

  depends_on = [azapi_resource.universal_llm_api]
}
