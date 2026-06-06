output "universal_llm_api_id" {
  description = "Resource ID of the Universal LLM API"
  value       = azapi_resource.universal_llm_api.id
}

output "universal_llm_api_name" {
  description = "Name of the Universal LLM API"
  value       = azapi_resource.universal_llm_api.name
}

output "universal_llm_api_path" {
  description = "Path of the Universal LLM API"
  value       = local.api_path
}

output "backend_ids" {
  description = "List of created backend IDs"
  value       = [for b in azapi_resource.llm_backend : b.name]
}

output "backend_pool_names" {
  description = "Map of model names to their backend pool names (for models with multiple backends)"
  value       = { for model, pool in azapi_resource.backend_pool : model => pool.name }
}

output "model_to_backend_map" {
  description = "Map of models to their direct backend IDs (for models with single backend)"
  value = {
    for model, backends in local.model_to_backends :
    model => backends[0].backend_id if length(backends) == 1
  }
}

output "policy_fragment_names" {
  description = "List of created policy fragment names"
  value = [
    azapi_resource.frag_set_backend_pools.name,
    azapi_resource.frag_set_backend_authorization.name,
    azapi_resource.frag_set_target_backend_pool.name,
    azapi_resource.frag_set_llm_requested_model.name,
    azapi_resource.frag_set_llm_usage.name,
    azapi_resource.frag_security_handler.name,
    azapi_resource.frag_validate_model_access.name,
    azapi_resource.frag_get_available_models.name,
    azapi_resource.frag_responses_id_security.name,
    azapi_resource.frag_responses_id_cache_store.name,
    azapi_resource.frag_set_response_headers.name,
    azapi_resource.frag_raise_throttling_events.name,
    azapi_resource.frag_ai_foundry_compatibility.name,
    azapi_resource.frag_strip_backend_headers.name
  ]
}
