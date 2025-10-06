variable "aws_region" {
	description = "AWS region for resources."
	type        = string
}
variable "app_name" {
	description = "The name of the application, used for tagging and resource naming."
	type        = string
}

variable "tags" {
	description = "Tags to apply to API Gateway resources."
	type        = map(string)
	default     = {}
}
