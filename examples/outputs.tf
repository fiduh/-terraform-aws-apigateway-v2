################################################################################
# API Gateway
################################################################################
output "api_id" {
  description = "The API identifier"
  value       = module.api_gateway.api_id
}

output "api_arn" {
  description = "The ARN of the API"
  value       = module.api_gateway.api_arn
}

################################################################################
# Integration(s)
################################################################################

output "integrations" {
  description = "Map of the integrations created and their attributes"
  value       = module.api_gateway.integrations
}

################################################################################
# Route(s)
################################################################################

output "routes" {
  description = "Map of the routes created and their attributes"
  value       = module.api_gateway.routes
}

################################################################################
# Stage
################################################################################
output "stage_id" {
  description = "The stage identifier"
  value       = module.api_gateway.stage_id
}

output "stage_arn" {
  description = "The stage ARN"
  value       = module.api_gateway.stage_arn
}

output "stage_invoke_url" {
  description = "The URL to invoke the API pointing to the stage"
  value       = module.api_gateway.stage_invoke_url
}