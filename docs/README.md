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
- 


#### Attach your integration to routes 

#### Stage

#### Deployment
