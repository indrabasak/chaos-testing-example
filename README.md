Chaos Testing Example
========================
This is a simple example of chaos testing in AWS using [localstack](https://docs.localstack.cloud/overview/).

## Sample Application
This project sample application consists of an [Amazon API Gateway](https://aws.amazon.com/api-gateway/) which
acts as an entry point to a REST API. This REST API has the following endpoints:
  - a mock `/test` endpoint, i.e., the endpoint generates API responses from the API Gateway directly (mock integration)
  - a `/v1/health` endpoint backed by a [AWS Lambda](https://aws.amazon.com/lambda/)
  - a `/v1/hello` endpoint backed by another AWS lambda

Our sample application also has a custom domain (`chaos-example.demo.com`) for easier access to the REST endpoints.

The API Gateway along with the mock integration, custom domain, and ACM certificate infrastructure code are created
using [Terraform](https://www.terraform.io/). While both the lambdas and the lambda integration with the API Gateway
are managed using the [Serverless framework](https://www.serverless.com/).

![](./img/chaos-testing-example.svg)
