include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "dynamodb" {
  config_path = "../dynamodb/"
  mock_outputs = {
        table_arn = "mock-table-arn"
    }
}

terraform {
  source = "../../../../terraform/modules/iam"
}

locals {
  app_name = include.root.locals.app_name
  tags     = include.root.locals.tags
  aws_region   = include.root.locals.aws_region
}

inputs = {
  app_name              = local.app_name
  dynamodb_table_arn    = dependency.dynamodb.outputs.table_arn
  tags                  = local.tags
  aws_region            = local.aws_region
}