include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../terraform/modules/devopsguru"
}

locals {
  project_name = include.root.locals.project_name
  app_name     = include.root.locals.app_name
  aws_region   = include.root.locals.aws_region
}

inputs = {
  app_boundary_key = local.project_name
  tag_values       = [ local.app_name ]
  aws_region      = local.aws_region
}