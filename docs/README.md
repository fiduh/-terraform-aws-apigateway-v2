# Design 
This document is intended to describe the decisions and assumptions that went into the current design of the Amazon API Gateway module(s). Various concepts of Amazon API Gateway are covered here to help align readers with the service and its capabilities and how they influence the design provided by this project.



# Terraform-aws-apigateway HTTP API/WebSocket

Amazon API Gateway is an AWS service for creating, publishing, maintaining, monitoring, and securing REST, HTTP, and WebSocket APIs at any scale.

HTTP APIs enable you to create RESTful APIs with lower latency and are designed with minimal features so that they can be offered at a lower price than it's REST APIs alternative which support more features such as API keys, per-client throttling, request validation, AWS WAF integration, or private API endpoints (use HTTP APIs if you don't need these features)


#### create an HTTP API 
HTTP API provides an HTTP endpoint

#### Create routes 
Routes are a way to send incoming API requests to backend resources. Routes consist of two parts: an HTTP method and a resource path, for example, GET /items. The ANY method matches all methods that you haven't defined for a resource. $default route acts as a catch-all for requests that don't match any other routes.

#### Create an integration
Integration to connect a route to backend resources. HTTP APIs support Lambda proxy, AWS service, Private and HTTP proxy integrations.
- AWS Lambda proxy integrations: enables you to integrate an API route with a Lambda function
    - Payload format version: specifies the format of the event that API Gateway sends to a Lambda integration, and how API Gateway interprets the response from Lambda. *payloadFormatVersion.* The supported values are 1.0 and 2.0.
- AWS service integrations: integrate your HTTP API with AWS services by using first-class integrations. You can use first-class integrations to send a message to an Amazon Simple Queue Service queue, or to start an AWS Step Functions state machine.
    - Create a first-class integration: Before you create a first-class integration, you must create an IAM role that grants API Gateway permissions to invoke the AWS service action that you're integrating with.
- Private integrations: enable you to create API integrations with private resources in a VPC, such as Application Load Balancers or Amazon ECS container-based applications.
    - To create a private integration, you must first create a VPC link.


#### Attach your integration to routes 

#### Stage
An API stage is a logical reference to a lifecycle state of your API (for example, dev, prod, beta, or v2). Each stage is a named reference to a deployment of the API and is made available for client applications to call. You can configure different integrations and settings for each stage of an API.
You can use stages and custom domain names to publish your API for clients to invoke.
- You can use custom domain names to provide a simpler, more intuitive URL for clients to invoke your API than the default URL, https://api-id.execute-api.region.amazonaws.com/stage.

#### Deployment
A deployment is a snapshot of your API configuration. After you deploy an API to a stage, it’s available for clients to invoke. You must deploy an API for changes to take effect. If you enable automatic deployments, changes to an API are automatically released for you.


#### Monitor
You can use CloudWatch metrics and CloudWatch Logs to monitor HTTP APIs. By combining logs and metrics, you can log errors and monitor your API's performance.
- Metrics

- Logging