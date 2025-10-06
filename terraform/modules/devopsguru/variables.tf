variable "aws_region" {
	description = "AWS region for resources."
	type        = string
}
variable "app_boundary_key" {
	description = "The key for the application boundary tag."
	type        = string
}

variable "tag_values" {
	description = "List of tag values for DevOps Guru resource collection."
	type        = list(string)
}
