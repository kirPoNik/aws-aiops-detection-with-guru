resource "aws_iam_role" "lambda_exec_role" {
	name = "${var.app_name}-lambda-exec-role"
	assume_role_policy = jsonencode({
		Version   = "2012-10-17",
		Statement = [{
			Action    = "sts:AssumeRole",
			Effect    = "Allow",
			Principal = { Service = "lambda.amazonaws.com" }
		}]
	})
	tags = var.tags
}

resource "aws_iam_role_policy" "lambda_policy" {
	name = "${var.app_name}-lambda-policy"
	role = aws_iam_role.lambda_exec_role.id
	policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{ Effect = "Allow", Action = ["dynamodb:PutItem"], Resource = var.dynamodb_table_arn },
			{ Effect = "Allow", Action = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"], Resource = "*" },
			{ Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" }
		]
	})
}
