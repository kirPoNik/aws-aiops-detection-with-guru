# Project-wide variables, shared across all environments
locals {
  app_name_prefix = "aiops-demo"
  project_name = "DevOps-Guru-App"
  aws_region   = "us-east-1"
  otel_lambda_layer_arns = {
    "us-east-1" = "arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-python-amd64-ver-1-32-0:2"
    "us-west-2" = "arn:aws:lambda:us-west-2:901920570463:layer:aws-otel-python-amd64-ver-1-32-0:2"
  }
  insights_extension_layers_arns = {
    "us-east-1" = "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension:60"
  }
}
