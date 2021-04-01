# AWS Lambda function
=============================

This module can be used to deploy an AWS Lambda function which is scheduled at the mentioned interval or rate.

Module Input Variables
----------------------

- `function_name` - Unique name for Lambda function
- `runtime` - A [valid](http://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html#options) Lambda runtime environment
- `lambda_file` - Path to zip archive containing Lambda function
- `source_code_hash` - the base64 encoded sha256 hash of the archive file - see TF [archive file provider](https://www.terraform.io/docs/providers/archive/d/archive_file.html)
- `handler` - The entrypoint into your Lambda function, in the form of `filename.function_name`
- `schedule_expression` - A [valid rate or cron expression](http://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html)
- `iam_role_arn` - A valid role arn AWS Lambda assumes when it executes Lambda function(https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
- `enabled` - Boolean expression. If false, the lambda function and the cloudwatch schedule are not set. Defaults to `true`
- `timeout` - The amount of time that Lambda allows a function to run before stopping it. The default is 3 seconds 
- `statement_id` - A unique statement identifier that differentiates the statement from others in the same policy
- `tags` - A map of tags to assign to the object

Usage
-----

```js

data "archive_file" "myfunction" {
  type        = "zip"
  source_file = "/valid/path/to/myfunction.py"
  output_path = "/valid/path/to/myfunction.zip"
}

data "aws_iam_role" "iam_role" {
   name = "my_lambda_role_name"
}

variable "tags" {
  type = "map"
  default = {
    Name = "your_app_name"
    owner = "owner_id"
    environment = "env_name"
  }
}

module "lambda_scheduled" {
  source              = "github.com/terraform-community-modules/tf_aws_lambda_function"
  function_name       = "my_lambda_function"
  runtime             = "python3.6"
  lambda_file         = "/valid/path/to/myfunction.zip"
  source_code_hash    = "${data.archive_file.myfunction.output_base64sha256}"
  handler             = "myfunction.handler"
  schedule_expression = "rate(5 hours)"
  timeout             = "30"
  statement_id        = "AllowExecutionFromCloudWatch"
  iam_role_arn        = "${data.aws_iam_role.iam_role.arn}"
  tags                = "${var.tags}"
}
```

Outputs
-------
- `lambda_arn` - ARN for the created Lambda function

