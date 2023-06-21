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

variable "root_domain" {
  type        = string
  description = "The domain name to associate with the API"
  default = "demo.com"
}

variable "subdomain"{
  type        = string
  description = "The subdomain for the API"
  default = "chaos-example.demo.com"
}
