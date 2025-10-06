resource "aws_apigatewayv2_api" "http_api" {
	name          = var.api_name
	protocol_type = "HTTP"
	tags          = var.tags
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
	api_id           = aws_apigatewayv2_api.http_api.id
	integration_type = "AWS_PROXY"
	integration_uri  = var.lambda_integration_uri
}

resource "aws_apigatewayv2_route" "api_route" {
	api_id    = aws_apigatewayv2_api.http_api.id
	route_key = var.route_key
	target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
	api_id      = aws_apigatewayv2_api.http_api.id
	name        = "$default"
	auto_deploy = true
}

resource "aws_lambda_permission" "api_gw_permission" {
	statement_id  = "AllowAPIGatewayInvoke"
	action        = "lambda:InvokeFunction"
	function_name = var.lambda_function_name
	principal     = "apigateway.amazonaws.com"
	source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
