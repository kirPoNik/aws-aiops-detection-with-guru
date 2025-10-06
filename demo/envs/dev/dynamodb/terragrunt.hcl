include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../terraform/modules/dynamodb"
}

locals {
  app_name = include.root.locals.app_name
  tags     = include.root.locals.tags
  aws_region   = include.root.locals.aws_region
}

inputs = {
  app_name              = local.app_name
  tags                  = local.tags
  aws_region            = local.aws_region
}