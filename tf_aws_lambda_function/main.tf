resource "aws_lambda_function" "lambda" {
  filename         = "${var.lambda_file}"
  function_name    = "${var.function_name}"
  role             = "${var.iam_role_arn}"
  handler          = "${var.handler}"
  source_code_hash = "${var.source_code_hash}"
  runtime          = "${var.runtime}"
  timeout          = "${var.timeout}"
  tags             = "${var.tags}"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "${var.statement_id}"
  action        = "lambda:InvokeFunction"
  function_name = "${var.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda.arn}"
}

resource "aws_cloudwatch_event_rule" "lambda" {
  name                = "${var.function_name}"
  schedule_expression = "${var.schedule_expression}"
  is_enabled          = "${var.enabled}"
}

resource "aws_cloudwatch_event_target" "lambda" {
  target_id = "${var.function_name}"
  rule      = "${aws_cloudwatch_event_rule.lambda.name}"
  arn       = "${aws_lambda_function.lambda.arn}"
}