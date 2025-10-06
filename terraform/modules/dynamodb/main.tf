resource "aws_dynamodb_table" "items_table" {
	name         = "${var.app_name}-items"
	billing_mode = "PAY_PER_REQUEST"
	hash_key     = "id"
	attribute   {
        name = "id"
        type = "S"
    }
	tags = var.tags
}
