variable "function_name" {}

variable "runtime" {}

variable "lambda_file" {}

variable "source_code_hash" {}

variable "handler" {}

variable "schedule_expression" {}

variable "enabled" {
  default = true
}

variable "iam_role_arn" {}

variable "timeout" {}

variable "tags" {
  type = "map"  
}

variable "statement_id" {}