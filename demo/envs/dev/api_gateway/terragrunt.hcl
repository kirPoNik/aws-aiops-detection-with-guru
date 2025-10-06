include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../terraform/modules/api_gateway"
}

dependency "lambda" {
  config_path = "../serverless_app/"
   mock_outputs = {
        lambda_function_invoke_arn = "arn:aws:apigateway::::::mock-lambda/invocations"
        lambda_function_name = "mock-lambda-function-name"
    }
}

locals {
  app_name = include.root.locals.app_name
  tags     = include.root.locals.tags
  aws_region   = include.root.locals.aws_region
}

inputs = {
  api_name              = "${local.app_name}-api"
  tags                  = local.tags
  lambda_integration_uri = dependency.lambda.outputs.lambda_function_invoke_arn
  route_key             = "POST /items"
  lambda_function_name  = dependency.lambda.outputs.lambda_function_name
  aws_region            = local.aws_region
}
