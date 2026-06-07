resource "azapi_update_resource" "this" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  resource_id = var.subnet_id

  body = {
    properties = {
      delegations = [
        {
          name = var.delegation_name
          properties = {
            serviceName = var.service_delegation_name
            actions     = var.actions
          }
        }
      ]
    }
  }
}
