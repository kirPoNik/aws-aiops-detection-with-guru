// API Gateway module outputs.tf
// Define outputs for API Gateway module

output "api_gateway_id" {
  description = "The ID of the API Gateway."
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_endpoint" {
  description = "The endpoint URL of the API Gateway."
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/items"
}