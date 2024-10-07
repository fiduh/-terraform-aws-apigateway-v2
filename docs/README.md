# Design 
This document is intended to describe the decisions and assumptions that went into the current design of the Amazon API Gateway module(s). Various concepts of Amazon API Gateway are covered here to help align readers with the service and its capabilities and how they influence the design provided by this project.

For more details see the [Amazon API Gateway WebSocket and HTTP API Reference](https://docs.aws.amazon.com/apigatewayv2/latest/api-reference/api-reference.html)

# Terraform-aws-apigateway HTTP API/WebSocket

Amazon API Gateway is an AWS service for creating, publishing, maintaining, monitoring, and securing REST, HTTP, and WebSocket APIs at any scale.

HTTP APIs enable you to create RESTful APIs with lower latency and are designed with minimal features so that they can be offered at a lower price than it's REST APIs alternative which support more features such as API keys, per-client throttling, request validation, AWS WAF integration, or private API endpoints (use HTTP APIs if you don't need these features)

HTTP APIs support OpenID Connect and OAuth 2.0 authorization. They come with built-in support for cross-origin resource sharing (CORS) and automatic deployments.


#### create an HTTP API 
HTTP API provides an HTTP endpoint
To create a functional API, you must have at least one route, integration, stage, and deployment.

#### Create routes 
Routes are a way to send incoming API requests to backend resources. Routes consist of two parts: an HTTP method and a resource path, for example, GET /items. The ANY method matches all methods that you haven't defined for a resource. $default route acts as a catch-all for requests that don't match any other routes.
- *Working with path variables*: For example, the GET /pets/{petID} route catches a GET request that a client submits to https://api-id.execute-api.us-east-2.amazonaws.com/pets/6.
- A *greedy path variable* catches all child resources of a route. To create a greedy path variable, add + to the variable name--for example, {proxy+}. The greedy path variable must be at the end of the resource path.
- *Working with query string parameters*: By default, API Gateway sends query string parameters to your backend integration if they are included in a request to an HTTP API. For example, when a client sends a request to https://api-id.execute-api.us-east-2.amazonaws.com/pets?id=4&type=dog, the query string parameter ?id=4&type=dog are sent to your integration.
- *Working with the $default route*: 

#### Routing API requests

#### Control and manage access to HTTP APIs in API Gateway
API Gateway supports multiple mechanisms for controlling and managing access to your HTTP API:
- *Lambda authorizers*
- *JWT authorizers*
- *Standard AWS IAM roles and policies*

#### Create integrations for HTTP APIs
Integration to connect a route to backend resources. HTTP APIs support Lambda proxy, AWS service, and HTTP proxy integrations. *For example, you can configure a POST request to the /signup route of your API to integrate with a Lambda function that handles signing up customers*
- *AWS Lambda proxy integrations*: enables you to integrate an API route with a Lambda function. When a client calls your API, API Gateway sends the request to the Lambda function and returns the function's response to the client.
    - Payload format version: specifies the format of the event that API Gateway sends to a Lambda integration, and how API Gateway interprets the response from Lambda. *payloadFormatVersion.* The supported values are 1.0 and 2.0.
- *AWS service integrations*: integrate your HTTP API with AWS services by using *first-class integrations*. A first-class integration connects an HTTP API route to an AWS service API. Whena client invokes a route that's backed by a first-class integration, API Gateway invokes an AWS service API for you. For example, you can use first-class integrations to send a message to an Amazon Simple Queue Service queue, or to start an AWS Step Functions state machine.
    - Create a first-class integration: Before you create a first-class integration, you must create an IAM role that grants API Gateway permissions to invoke the AWS service action that you're integrating with.
- *Private integrations*: enable you to create API integrations with private resources in a VPC, such as Application Load Balancers or Amazon ECS container-based applications.
    - To create a private integration, you must first create a VPC link.


#### Attach your integration to routes 

#### Configure CORS for HTTP APIs 
Cross-origin resource sharing (CORS) is a browser security feature that restricts HTTP requests that are initiated from scripts running in the browser. If you cannot access your API and receive an error message that contains Cross-Origin Request Blocked, you might need to enable CORS.

#### Transform API requests and responses for HTTP APIs

#### Publish HTTP APIs for customers to invoke
You can use stages and custom domain name to publish your API for clients to invoke.
An API stage is a logical reference to a lifecycle state of your API (for example, dev, prod, beta, or v2). Each stage is a named reference to a deployment of the API and is made available for client applications to call. You can configure different integrations and settings for each stage of an API.
You can use stages and custom domain names to publish your API for clients to invoke.
- You can use custom domain names to provide a simpler, more intuitive URL for clients to invoke your API than the default URL, https://api-id.execute-api.region.amazonaws.com/stage.
- *Stages*: An API stage is a logical reference to a lifecycle state of your API (for example, dev, prod, beta, or v2). API stages are identified by their API ID and stage name, and they're included in the URL you use to invoke the API. Each stage is a named reference to a deployment of the API and is made available for client applications to call.

You can create a $default stage that is served from the base of your API's URL—for example, https://{api_id}.execute-api.{region}.amazonaws.com/. You use this URL to invoke an API stage.

A deployment is a snapshot of your API configuration. After you deploy an API to a stage, it’s available for clients to invoke. You must deploy an API for changes to take effect. If you enable automatic deployments, changes to an API are automatically released for you.
    - Use stage variables for HTTP APIs: Stage variables are key-value pairs that you can define for a stage of an HTTP API. They act like environment variables and can be used in your API setup. Stage variables are not intended to be used for sensitive data, such as credentials.
    - Example: you can use stage variables to specify a different AWS Lambda function integration for each stage of your API. You can tell API Gateway to use the stage variable value, http://${stageVariables.url}. This value tells API Gateway to substitute your stage variable ${} at runtime, depending on the stage of your API.
    - When specifying a Lambda function name as a stage variable value, you must configure the permissions on the Lambda function manually.
- *Security Policy*:
- *Custom domain names*: Custom domain names are simpler and more intuitive URLs that you can provide to your API users. 

After deploying your API, you (and your customers) can invoke the API using the default base URL of the following format: 
``` 
https://api-id.execute-api.region.amazonaws.com/stage
```
    - With custom domain names, you can set up your API's hostname, and choose a base path (for example, myservice) to map the alternative URL to your API. For example, a more user-friendly API base URL can become:
    ```
    https://api.example.com/myservice
    ```
#### Map API stages to a custom domain name
You use API mappings to connect API stages to a custom domain name. After you create a domain name and configure DNS records, you use API mappings to send traffic to your APIs through your custom domain name.

An API mapping specifies an API, a stage, and optionally a path to use for the mapping. For example, you can map the production stage of an API to https://api.example.com/orders.

You can map HTTP and REST API stages to the same custom domain name.
Before you create an API mapping, you must have an API, a stage, and a custom domain name. To learn more about creating a custom domain name.
    - Disable the default endpoint for HTTP APIs: By default, clients can invoke your API by using the execute-api endpoint that API Gateway generates for your API. To ensure that clients can access your API only by using a custom domain name, disable the default execute-api endpoint. When you disable the default endpoint, it affects all stages of an API. After you disable the default endpoint, you must deploy your API for the change to take effect, unless automatic deployments are enabled.

#### Protect your HTTP APIs
API Gateway provides a number of ways to protect your API from certain threats, like malicious users or spikes in traffic. You can protect your API using strategies like setting throttling targets, and enabling mutual TLS.
- *Throttling*: You can configure throttling for your APIs to help protect them from being overwhelmed by too many requests. Throttles are applied on a best-effort basis and should be thought of as targets rather than guaranteed request ceilings.
- *Mutual TLS*

#### Deployment
A deployment is a point-in-time snapshot of your API configuration. After you deploy an API to a stage, it’s available for clients to invoke. You must deploy an API for changes to take effect. If you enable automatic deployments, changes to an API are automatically released for you.


#### Monitor
You can use CloudWatch metrics and CloudWatch Logs to monitor HTTP APIs. By combining logs and metrics, you can log errors and monitor your API's performance.
- *Metrics*: CloudWatch metrics for HTTP APIs
    - You can monitor API execution by using CloudWatch, which collects and processes raw data from API Gateway into readable, near-real-time metrics. These statistics are recorded for a period of 15 months so you can access historical information and gain a better perspective on how your web application or service is performing.
    - By default, API Gateway metric data is automatically sent to CloudWatch in one-minute periods. To monitor your metrics, create a CloudWatch dashboard for your API.

- *Logging*: Configure logging for HTTP APIs
    - You can turn on logging to write logs to CloudWatch Logs. You can use [logging variables](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging-variables.html) to customize the content of your logs.