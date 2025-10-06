include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # Change the source to the official Terraform AWS Lambda module.
  # Pinning the version is a best practice to avoid unexpected changes.
  source = "tfr:///terraform-aws-modules/lambda/aws?version=8.1.0"
}

dependency "iam" {
  config_path = "../iam/"
  mock_outputs = {
        lambda_role_arn = "arn:aws:iam::123456789012:role/mock-lambda-role"
    }
}

dependency "dynamodb" {
  config_path = "../dynamodb/"
  mock_outputs = {
        table_name = "mock-table-name"
  }
}

locals {
  app_name = include.root.locals.app_name
  tags     = include.root.locals.tags
  otel_layer_arn = include.root.locals.otel_layer_arn
  insights_extension_layer_arn = include.root.locals.insights_extension_layer_arn
  aws_region   = include.root.locals.aws_region
  related_path = "${path_relative_from_include()}"
  root_path  = "${get_repo_root()}"
}

# The inputs are now structured to match the public module's variables.
inputs = {
  function_name = "${local.app_name}-primary-function"
  handler       = "app.handler"
  runtime       = "python3.12"
  memory_size   = 256
  timeout       = 10
  layers        = [local.otel_layer_arn]

  ## Tell the module  to create a package, as we are providing one.
  create_package = true
  source_path = "\"${path_relative_from_include()}/../../../src\""

  cloudwatch_logs_retention_in_days = 14
  cloudwatch_logs_skip_destroy = false
  use_existing_cloudwatch_log_group = false
  logging_log_group  = "/aws/lambda/${local.app_name}-primary-function"

  # We are managing the IAM role separately, so we tell the module not to create one.
  create_role = false
  # Pass the ARN of the IAM role from our dedicated 'iam' component.
  lambda_role = dependency.iam.outputs.lambda_role_arn

  environment_variables = {
    TABLE_NAME                         = dependency.dynamodb.outputs.table_name
    AWS_LAMBDA_EXEC_WRAPPER            = "/opt/otel-instrument"  # OpenTelemetry auto-instrumentation. see https://aws-otel.github.io/docs/getting-started/lambda/lambda-python
    OPENTELEMETRY_COLLECTOR_CONFIG_URI = "/var/task/collector.yaml" # Custom collector config in our Lambda package
    OTEL_PYTHON_DISABLED_INSTRUMENTATIONS = "redis,kafka,django,elasticsearch,pymysql,mysql,falcon,fastapi,flask,grpc,sqlalchemy,billiard,jinja2,asyncpg,tornado"  # Disable some auto-instrumentations that are not needed
    PROJECT_NAME                       = local.app_name
    LOG_GROUP_NAME                     = "/aws/lambda/${local.app_name}-primary-function"
    ## INJECT_LATENCY                     = "true" # Uncomment to simulate latency for testing purposes
  }
 
  tracing_mode = "Active"

  tracing_config = {
    mode = "Active"
  }

  tags = local.tags
}
