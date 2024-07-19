################################################################################
# API Gateway
################################################################################
output "api_id" {
  description = "The API identifier"
  value       = try(aws_apigatewayv2_api.this[0].id, null)
}

output "api_arn" {
  description = "The ARN of the API"
  value       = try(aws_apigatewayv2_api.this[0].arn, null)
}

output "api_execution_arn" {
  description = "The ARN prefix to be used in an `aws_lambda_permission`'s `source_arn` attribute or in an `aws_iam_policy` to authorize access to the `@connections` API"
  value       = try(aws_apigatewayv2_api.this[0].execution_arn, null)
}


################################################################################
# Integration(s)
################################################################################

output "integrations" {
  description = "Map of the integrations created and their attributes"
  value       = aws_apigatewayv2_integration.this
}



################################################################################
# Route(s)
################################################################################
output "routes" {
  description = "Map of the routes created and their attributes"
  value       = aws_apigatewayv2_route.this
}



################################################################################
# Stage
################################################################################

output "stage_id" {
  description = "The stage identifier"
  value       = try(aws_apigatewayv2_stage.this[0].id, null)
}

output "stage_arn" {
  description = "The stage ARN"
  value       = try(aws_apigatewayv2_stage.this[0].arn, null)
}

output "stage_invoke_url" {
  description = "The URL to invoke the API pointing to the stage"
  value       = try(aws_apigatewayv2_stage.this[0].invoke_url, null)
}

