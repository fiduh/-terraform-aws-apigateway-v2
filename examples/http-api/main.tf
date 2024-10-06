provider "aws" {
  region = local.region
}

locals {
  name = "api-gateway-demo"
  region = "us-east-1"
  function_name1 = "demoNodeJS"
}

module "api_gateway" {
   source = "../../modules/http-api"
  
  #source = "git::https://gitlab.com/aws-terraform-modules2/terraform-aws-apigateway.git//modules/http-api?ref=v0.0.1"
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

     "ANY /api/auth/{x}" = {
      detailed_metrics_enabled = false

      integration = {
        function_name = local.function_name1
        payload_format_version = "2.0"
      }
    }

    "ANY /api/ticket" = {
      integration = {
        function_name = local.function_name1
        type            = "AWS_PROXY"
        payload_format_version = "1.0"
      }
    }

    "ANY /api/ticket/status" = {
      integration = {
        function_name = local.function_name1
        payload_format_version = "1.0"
      }
    }

    "ANY /api/ticket/archive" = {
      integration = {
        function_name = local.function_name1
        payload_format_version = "1.0"
      }
    }

    "ANY /api/ticket/reply-email" = {
      integration = {
        function_name = local.function_name1
        type            = "AWS_PROXY"
        payload_format_version = "1.0"
      }
    }

    "ANY /api/ticket/replytick" = {
      integration = {
        function_name = local.function_name1
        type            = "AWS_PROXY"
        payload_format_version = "1.0"
      }
    }
  }

  stages = {

    stage = {
      stage_name = "stage"
      description = "Stage environment"
      stage_variables = {
        lambdaAlias = "stage"
      }
      tags = {}
      deploy = true
    }
  }

}



################################################################################
# Supporting Resources
################################################################################

output "lambda_function_name" {
  description = "Lambda inokation URI"
  value = aws_lambda_function.this.function_name
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

# Lambda Function
resource "aws_lambda_function" "this" {
  function_name = "demoAPIFunction"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

resource "aws_lambda_permission" "apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}