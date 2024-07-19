locals {
  is_http      = var.protocol_type == "HTTP"
  create_routes_and_integrations = var.create && var.create_routes_and_integrations 
}

################################################################################
# API Gateway
################################################################################

resource "aws_apigatewayv2_api" "this" {
  count = var.create ? 1 : 0

  dynamic "cors_configuration" {
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
  for_each = { for k, v in var.routes : k => v if local.create_routes_and_integrations }
  api_id    = aws_apigatewayv2_api.this[0].id

  route_key = each.key
  target  = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}



################################################################################
# Integration(s)
################################################################################

resource "aws_apigatewayv2_integration" "this" {
  for_each = { for k, v in var.routes : k => v.integration if local.create_routes_and_integrations }

  api_id           = aws_apigatewayv2_api.this[0].id
  integration_type = each.value.type

  connection_type           = each.value.connection_type
  content_handling_strategy = each.value.content_handling_strategy
  description               = each.value.description
  integration_method        = each.value.method
  integration_uri           = each.value.uri
  passthrough_behavior      = each.value.passthrough_behavior
  payload_format_version    = each.value.payload_format_version
  credentials_arn           = each.value.credentials_arn

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
resource "aws_apigatewayv2_stage" "this" {
  count = local.create_stage ? 1 : 0

  auto_deploy = local.is_http ? true : null

  api_id = aws_apigatewayv2_api.this[0].id
  description   = var.stage_description
  name   = var.stage_name 

  stage_variables = var.stage_variables

  tags = merge(var.tags, var.stage_tags)

  depends_on = [
    aws_apigatewayv2_route.this
  ]
}



################################################################################
# Deployment
################################################################################

resource "aws_apigatewayv2_deployment" "this" {
  count = local.create_stage && var.deploy_stage && !local.is_http ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  description = var.description

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.this),
      jsonencode(aws_apigatewayv2_route.this),
      jsonencode(aws_apigatewayv2_api.this[0].body),
    ])))
  }

  depends_on = [
    aws_apigatewayv2_api.this,
    aws_apigatewayv2_route.this,
    aws_apigatewayv2_integration.this,
  ]

  lifecycle {
    create_before_destroy = true
  }
}




