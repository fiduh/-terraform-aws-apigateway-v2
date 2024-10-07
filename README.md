# Amazon API Gateway Version 2 Terraform module

Terraform module which creates HTTP API resources on AWS.
*Amazon API Gateway Version 2 resources are used for creating and deploying WebSocket and HTTP APIs.*

# Available Features
For more details see the [design docs](docs/README.md) 

# Usage

#### HTTP API Gateway

```hcl 
module "api_gateway" {
  source = "git::https://gitlab.com/aws-terraform-modules2/terraform-aws-apigateway.git//modules/http-api?ref=v0.0.1"

  # API
  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  name = "api-test"
  description      = "Ticketing HTTP API Gateway"


  # Routes & Integration(s)
  routes = {

     "ANY /auth/{x}" = {
      detailed_metrics_enabled = false

      integration = {
        uri = aws_lambda_function.this.invoke_arn
        payload_format_version = "2.0"
      }
    }

    "POST /api/ticket" = {
      integration = {
        uri = aws_lambda_function.this.invoke_arn
        type            = "AWS_PROXY"
        payload_format_version = "1.0"
      }
    }

    "GET /api/ticket/status" = {
      integration = {
        uri = aws_lambda_function.this.invoke_arn
        payload_format_version = "1.0"
      }
    }


}
```

#### Fallback Mechanism for Lambda Alias Values: Due to the fact that you can't pass $LATEST as stageVariables to API Gateway, to implement a default stage variable that points to $LATEST lambda alias, you have to create a DEV alias in Lambda that points to $LATEST and create a default dev stage variable in API Gateway that points to DEV alias.