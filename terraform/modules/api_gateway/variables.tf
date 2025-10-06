variable "aws_region" {
	description = "AWS region for resources."
	type        = string
}
variable "api_name" {
	description = "Name of the API Gateway."
	type        = string
}

variable "tags" {
	description = "Tags to apply to API Gateway resources."
	type        = map(string)
	default     = {}
}

variable "lambda_integration_uri" {
	description = "Lambda function invoke ARN for integration."
	type        = string
}

variable "route_key" {
	description = "Route key for API Gateway route."
	type        = string
	default     = "POST /items"
}

variable "lambda_function_name" {
	description = "Lambda function name for permission resource."
	type        = string
}
