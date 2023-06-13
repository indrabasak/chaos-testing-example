variable "rest_api_name" {
  type = string
  description = "Chaos Testing Example"
  default = "api-gateway-chaos-example"
}

variable "rest_api_stage_name" {
  type        = string
  description = "Chaos Testing API Gateway stage"
  default     = "sbx"
}
