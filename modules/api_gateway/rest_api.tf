resource "aws_api_gateway_rest_api" "rest_api"{
  name = var.rest_api_name
}

resource "aws_api_gateway_resource" "rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "test"
}

resource "aws_api_gateway_method" "rest_api_get_method"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.rest_api_get_method.http_method
  type = "MOCK"
  //request_tempates is required to explicitly set the statusCode to an integer value of 200
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "rest_api_get_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.rest_api_get_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_integration.rest_api_get_method_integration.http_method
  status_code = aws_api_gateway_method_response.rest_api_get_method_response_200.status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from Chaos Testing"
    })
  }
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.rest_api_resource.id,
      aws_api_gateway_method.rest_api_get_method.id,
      aws_api_gateway_integration.rest_api_get_method_integration.id
    ]))
  }
}

resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.rest_api_stage_name
}

#data "aws_api_gateway_export" "rest_api_gateway_export" {
#  rest_api_id = aws_api_gateway_stage.rest_api_stage.rest_api_id
#  stage_name  = aws_api_gateway_stage.rest_api_stage.stage_name
#  export_type = "oas30"
#}

resource "aws_ssm_parameter" "ssm_parameter_rest_api_id" {
  name        = "/chaos-testing-example/rest_api_id"
  description = "Chaos Testing API Gateway REST API ID"
  type        = "String"
  value       = aws_api_gateway_stage.rest_api_stage.rest_api_id
}

resource "aws_ssm_parameter" "ssm_parameter_rest_api_root_resource_id" {
  name        = "/chaos-testing-example/root_resource_id"
  description = "Chaos Testing API Gateway Root Resource API ID"
  type        = "String"
  value       = aws_api_gateway_rest_api.rest_api.root_resource_id
}
