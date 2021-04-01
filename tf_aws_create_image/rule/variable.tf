variable "rule_name" {}

variable "schedule" {}

variable "image_name" {}

variable "instance_name" {}

variable "image_description" {}

variable "disable_rule" {}

variable "web_hook" {}

variable "lambda_name" {}

variable "action" {
  default = "lambda:InvokeFunction"
}

variable "lambda_arn" {}
