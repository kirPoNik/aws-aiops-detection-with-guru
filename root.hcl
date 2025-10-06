locals {
  # Read the raw variables from the hierarchy of config files.
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # This is the single place where all variables are composed.
  environment  = local.env_vars.locals.environment
  aws_region   = local.project_vars.locals.aws_region
  project_name = local.project_vars.locals.project_name
  app_name     = "${local.project_vars.locals.app_name_prefix}-${local.environment}"
  # app_name = "test-app" # Temporary hardcoded value for testing

  # Add this line to look up the correct ARN for the current region
  otel_layer_arn = lookup(local.project_vars.locals.otel_lambda_layer_arns, local.aws_region, "arn-not-found-for-region")
  insights_extension_layer_arn  = lookup(local.project_vars.locals.insights_extension_layers_arns, local.aws_region, "arn-not-found-for-region")

  # Compose the final tags map here.
  tags = {
    app_name     = local.app_name
    project_name = local.project_name
    env          = local.environment
    aws_region   = local.aws_region
    # This tag is for DevOps Guru resource grouping
    "${local.project_name}" = local.app_name
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

remote_state {
    backend = "local"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite"
    }
    config = {
        path = "${get_terragrunt_dir()}/terraform.tfstate"
    }
}
