resource "aws_cloudwatch_event_rule" "rule" {
  name                = "${var.rule_name}"
  description         = "Causes the Create Instance Lambda to be run by a shcedule, disabled on first successfull run"
  schedule_expression = "${var.schedule}"
}

resource "aws_lambda_permission" "permission" {
  statement_id  = "${var.rule_name}"
  action        = "${var.action}"
  function_name = "${var.lambda_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.rule.arn}"
}

data "template_file" "input_json" {
  template = "{ \"instanceName\" : \"$${instanceName}\",\"imageName\" : \"$${imageName}\", \"ruleName\" : \"$${ruleName}\", \"description\" : \"$${description}\", \"webHook\" : \"$${webHook}\", \"disableRule\" : \"$${disableRule}\" }"

  vars = {
    instanceName = "${var.instance_name}"
    imageName    = "${var.image_name}"
    ruleName     = "${aws_cloudwatch_event_rule.rule.name}"
    description  = "${var.image_description}"
    webHook      = "${var.web_hook}"
    disableRule  = "${var.disable_rule}"
  }
}

# Target
resource "aws_cloudwatch_event_target" "target" {
  rule      = "${aws_cloudwatch_event_rule.rule.name}"
  target_id = "${aws_cloudwatch_event_rule.rule.name}"
  arn       = "${var.lambda_arn}"
  input     = "${data.template_file.input_json.rendered}"
}
