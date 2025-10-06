resource "aws_devopsguru_resource_collection" "app_collection" {
	type = "AWS_TAGS"
	tags {
		app_boundary_key = var.app_boundary_key
		tag_values       = var.tag_values
	}
}