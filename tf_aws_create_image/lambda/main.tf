resource "aws_iam_role" "lambda" {
  name = "${var.lambda_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "LambdaCloudwatchLogs",
        "Effect": "Allow",
        "Action": [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateImage",
          "ec2:DeregisterImage", 
          "ec2:DescribeImages",
          "ec2:DescribeInstances"
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Resource": [
          "arn:aws:events:*:*:rule/${var.allowed_rules_resource}"
          ],
        "Action": [
          "events:DisableRule"
        ]
      }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_policy_att" {
  name       = "${var.lambda_name}"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_iam_instance_profile" "newswires_lambda_profile" {
  name = "${var.lambda_name}"
  role = "${aws_iam_role.lambda.name}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "./files/create_image_lambda.zip"
  function_name    = "${var.lambda_name}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "create_image_lambda.handler"
  source_code_hash = "${base64sha256(file("./files/create_image_lambda.zip"))}"
  runtime          = "nodejs6.10"
  timeout          = 30
}

output "lambda_arn" {
  value = "${aws_lambda_function.lambda.arn}"
}