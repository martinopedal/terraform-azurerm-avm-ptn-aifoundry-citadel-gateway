# Networking Module

This module handles VNet creation or references existing VNets for the Citadel Gateway.

## Features
- Create new VNet with 4 subnets (APIM, Private Endpoints, Function App, Agents)
- Reference existing VNet and subnets (BYO scenario)
- NSG configuration for each subnet
- Route table for APIM subnet
- Private DNS zone creation (when not using existing VNet)
- Conditional Agent subnet for AI Foundry network injection

## Usage

```hcl
module "networking" {
  source = "./modules/networking"
  
  # ... parameters
}
```
