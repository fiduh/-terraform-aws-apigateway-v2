locals {
  is_http      = var.protocol_type == "HTTP"
  create_routes_and_integrations = var.create && var.create_routes_and_integrations 
}

################################################################################
# API Gateway
################################################################################

resource "aws_apigatewayv2_api" "this" {
  # Only create this resource if `var.create` is true
  count = var.create ? 1 : 0

  dynamic "cors_configuration" {
    # Only add CORS configuration if is_http is true and cors_configuration variable is not empty.
    for_each = local.is_http && length(var.cors_configuration) > 0 ? [var.cors_configuration] : []

    content {
      allow_credentials = cors_configuration.value.allow_credentials
      allow_headers     = cors_configuration.value.allow_headers
      allow_methods     = cors_configuration.value.allow_methods
      allow_origins     = cors_configuration.value.allow_origins
      expose_headers    = cors_configuration.value.expose_headers
      max_age           = cors_configuration.value.max_age
    }
  }

  credentials_arn = var.credentials_arn

  description = var.description
  name          = var.name
  protocol_type = var.protocol_type
  version = var.api_version

  tags = merge(
    var.tags,
    {terraform-aws-module: "apigateway-v2"}
  )
}



################################################################################
# Route(s)
################################################################################
resource "aws_apigatewayv2_route" "this" {
  #  Iterates over var.routes if create_routes_and_integrations is true, creating a route for each entry.
  for_each = { for k, v in var.routes : k => v if local.create_routes_and_integrations }

  # Links the route to the API Gateway instance.
  api_id    = aws_apigatewayv2_api.this[0].id

  # Sets the route key from the key of each entry.
  route_key = each.key

  # Sets the integration target for the route.
  target  = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}



################################################################################
# Integration(s)
################################################################################
locals {
  region = data.aws_region.current.name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


resource "aws_apigatewayv2_integration" "this" {
   #for_each = { for stage_name, stage in var.stages : stage_name => stage.integrations if local.create_routes_and_integrations}

  #Iterates over var.routes if create_routes_and_integrations is true, creating an integration for each entry.
  for_each = { for k, v in var.routes : k => v.integration if local.create_routes_and_integrations }
  

  api_id           = aws_apigatewayv2_api.this[0].id

  # Sets the integration type from the route's integration type.
  integration_type = each.value.type

  # The type of the network connection to the integration endpoint. Specify INTERNET for connections through the public routable internet or VPC_LINK for private connections between API Gateway and resources in a VPC. The default value is INTERNET.
  connection_type           = each.value.connection_type

  description               = each.value.description

  # Specifies the integration's HTTP method type.
  integration_method        = each.value.method

  # For a Lambda integration, specify the URI of a Lambda function.
  #integration_uri = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${local.region}:${data.aws_caller_identity.current.account_id}:function:${each.value.function_name}:$${stageVariables.functionAlias}/invocations"
  integration_uri  = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${local.region}:${data.aws_caller_identity.current.account_id}:function:${each.value.function_name}${contains(each.value.stage_variables, "") ? "" : ":$${stageVariable.functionAlias}"}/invocations"


  #integration_uri = each.value.uri

  #integration_uri = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${local.region}:${data.aws_caller_identity.current.account_id}:function:$${stageVariables.function}/invocations"

  #integration_uri           = each.value.uri
  payload_format_version    = each.value.payload_format_version

  # Specifies the credentials required for the integration, if any. three options are available. To specify an IAM Role for API Gateway to assume, use the role's Amazon Resource Name (ARN). To require that the caller's identity be passed through from the request, specify the string arn:aws:iam::*:user/*. To use resource-based permissions on supported AWS services, don't specify this parameter.
  credentials_arn           = each.value.credentials_arn

  #Ensures the integration is created before destroying the old one during updates.
  lifecycle {
    create_before_destroy = true
  }

}



################################################################################
# Stage
################################################################################
locals {
  create_stage = var.create && var.create_stage 
}
#resource "aws_apigatewayv2_stage" "this" {

  # Creates the stage if create_stage is true.
  #count = local.create_stage ? 1 : 0

  # Enables automatic deployment if protocol_type is "HTTP".
  #auto_deploy = local.is_http ? true : null

  #api_id = aws_apigatewayv2_api.this[0].id
  #description   = var.stage_description

  # Sets the stage name from the variable.
  #name   = var.stage_name 

  # Sets stage variables from the variable.
  #stage_variables = var.stage_variables

  # Merges the provided tags with additional stage-specific tags.
  #tags = merge(var.tags, var.stage_tags)

  # Ensures the stage is created after the routes.
  #depends_on = [
   # aws_apigatewayv2_route.this
 # ]
#}
resource "aws_apigatewayv2_stage" "this" {
  #for_each = { for k, v in var.routes : k => v.stage if var.create  }


  # Creates the stage if create_stage is true.
  for_each = { for stage_name, stage in var.stages : stage_name => stage if var.create && stage.deploy }

  # Enables automatic deployment if protocol_type is "HTTP".
  auto_deploy = local.is_http ? true : null

  api_id = aws_apigatewayv2_api.this[0].id
  description   = each.value.description

  # Sets the stage name from the variable.
  name   = each.value.stage_name 

  # Sets stage variables from the variable.
  stage_variables = each.value.stage_variables

  # Merges the provided tags with additional stage-specific tags.
  tags = merge(var.tags, each.value.tags)

  # Ensures the stage is created after the routes.
  depends_on = [
    aws_apigatewayv2_route.this
  ]
}




################################################################################
# Deployment
################################################################################

resource "aws_apigatewayv2_deployment" "this" {

  # Creates the deployment if create_stage and deploy_stage are true and protocol_type is not "HTTP".
  count = local.create_stage && var.deploy_stage && !local.is_http ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  description = var.description

  # Forces a new deployment when the specified resources change.
  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.this),
      jsonencode(aws_apigatewayv2_route.this),
      jsonencode(aws_apigatewayv2_api.this[0].body),
    ])))
  }

  # Ensures the deployment is created after the API, routes, and integrations.
  depends_on = [
    aws_apigatewayv2_api.this,
    aws_apigatewayv2_route.this,
    aws_apigatewayv2_integration.this,
  ]

  lifecycle {
    create_before_destroy = true
  }
}




