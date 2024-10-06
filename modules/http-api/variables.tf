variable "create" {
  description = "Controls if resources should be created"
  type        = bool
  default     = true
}
variable "tags" {
  description = "A mapping of tags to assign to API gateway resources"
  type        = map(string)
  default     = {}
}

################################################################################
# API Gateway
################################################################################

variable "cors_configuration" {
  description = "The cross-origin resource sharing (CORS) configuration. Applicable for HTTP APIs"
  type = object({
    allow_credentials = optional(bool)
    allow_headers     = optional(list(string))
    allow_methods     = optional(list(string))
    allow_origins     = optional(list(string))
    expose_headers    = optional(list(string), [])
    max_age           = optional(number)
  })
  default = {}
}

variable "credentials_arn" {
  description = "Part of quick create. Specifies any credentials required for the integration. Applicable for HTTP APIs"
  type        = string
  default     = null
}

variable "description" {
  description = "The description of the API. Must be less than or equal to 1024 characters in length"
  type        = string
  default     = null
}


variable "name" {
  description = "The name of the API. Must be less than or equal to 128 characters in length"
  type        = string
  default     = ""
}

variable "protocol_type" {
  description = "The API protocol. Valid values: `HTTP`, `WEBSOCKET`"
  type        = string
  default     = "HTTP"
}

variable "api_version" {
  description = "A version identifier for the API. Must be between 1 and 64 characters in length"
  type        = string
  default     = null
}


################################################################################
# Route(s) & Integration(s)
################################################################################

variable "create_routes_and_integrations" {
  description = "Whether to create routes and integrations resources"
  type        = bool
  default     = true
}

variable "routes" {
  description = "Map of API gateway routes with integrations"
  type = map(object({

    # Route settings
    data_trace_enabled       = optional(bool)
    detailed_metrics_enabled = optional(bool)
    logging_level            = optional(string)


    # Integration
    integration = object({
      connection_type           = optional(string)
      content_handling_strategy = optional(string)
      credentials_arn           = optional(string)
      description               = optional(string)
      method                    = optional(string)
      type                      = optional(string, "AWS_PROXY")
      function_name             = optional(string)
      passthrough_behavior      = optional(string)
      payload_format_version    = optional(string)

    })

  }))
  default = {}
}



################################################################################
# Stage
################################################################################

variable "create_stage" {
  description = "Whether to create default stage"
  type        = bool
  default     = true
}

variable "stage_access_log_settings" {
  description = "Settings for logging access in this stage. Use the aws_api_gateway_account resource to configure [permissions for CloudWatch Logging](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#set-up-access-logging-permissions)"
  type = object({
    create_log_group            = optional(bool, true)
    destination_arn             = optional(string)
    format                      = optional(string)
    log_group_name              = optional(string)
    log_group_retention_in_days = optional(number, 30)
    log_group_kms_key_id        = optional(string)
    log_group_skip_destroy      = optional(bool)
    log_group_class             = optional(string)
    log_group_tags              = optional(map(string), {})
  })
  default = {}
}

variable "stage_default_route_settings" {
  description = "The default route settings for the stage"
  type = object({
    data_trace_enabled       = optional(bool, true)
    detailed_metrics_enabled = optional(bool, true)
    logging_level            = optional(string)
    throttling_burst_limit   = optional(number, 500)
    throttling_rate_limit    = optional(number, 1000)
  })
  default = {}
}

variable "stages" {
  type = map(object({
    stage_name = optional(string)
    description = optional(string)
    stage_variables = optional(map(string))
    tags = optional(map(string))
    deploy = optional(bool)
  }))

  default = {
     default = {
      stage_name = "$default"
      description = "Default environment"
      stage_variables = {
        lambdaAlias = "$LATEST"
      }
      tags = {}
      deploy = true
    }

  }
}


################################################################################
# Deployment
################################################################################

variable "deploy_stage" {
  description = "Whether to deploy the stage. `HTTP` APIs are auto-deployed by default"
  type        = bool
  default     = true
}