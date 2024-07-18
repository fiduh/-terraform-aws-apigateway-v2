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
      uri                       = optional(string)
      passthrough_behavior      = optional(string)
      payload_format_version    = optional(string)

    })
  }))
  default = {}
}



################################################################################
# Stage
################################################################################



################################################################################
# Deployment
################################################################################