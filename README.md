# Amazon API Gateway Version 2 Terraform module

Terraform module which creates HTTP API resources on AWS.
*Amazon API Gateway Version 2 resources are used for creating and deploying WebSocket and HTTP APIs.*

# Available Features
For more details see the [design docs](docs/README.md) 

# Usage

#### HTTP API Gateway

```hcl 
module "api_gateway" {
  source = "../../modules/http-api"

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