provider "aws" {
  region = local.region
}

locals {
  name = "api-gateway-test"
  region = "us-east-1"
}

module "aws-api-gateway" {
  source = "../../modules/http-api"

  # API
  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  name = local.name
  description      = "Ticketing HTTP API Gateway"


  # Routes & Integration(s)
  routes = {

     "ANY /" = {
      detailed_metrics_enabled = false

      integration = {
        payload_format_version = "2.0"
      }
    }

    "POST /start-step-function" = {
      integration = {
        type            = "AWS_PROXY"

        payload_format_version = "1.0"
      }
    }
  }


}