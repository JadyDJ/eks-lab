#
# Module: tf_aws_userdata
#

variable "chef_cookbook_version" {
  description = "set to latest or the cookbook version you want to target."
  default     = "latest"
}

variable "chef_cookbook" {
  description = "Name of cookbook"
}

variable "chef_interval" {
  description = "cron for the frequency of chef interval (set to 0 for no cron)"
  default     = "0"
}

variable "chef_env" {
  description = "Name of the environment file"
  # The name of the environment file you want to target (no extension)
}

variable "chef_role" {
  description = "Name of the role file"
  # The name of the role file you want to target (no extension)
}

variable "region" {
  description = "Name of the Region"
  default     = "us-east-1"
  # The name of the role file you want to target (no extension)
}

variable "stack_name" {
  description = "Name of the stack"
  default     = "terraform_stack"
  # The name of the role file you want to target (no extension)
}

variable "lc_name" {
  description = "Name of the lc"
  default     = "terraform_stack_lc"
  # The name of the role file you want to target (no extension)
}

variable "stack_id" {
  description = "Unique ID for stack"
  default     = "terraform_stack_id"
  # The name of the role file you want to target (no extension)
}

variable "s3_bucket" {
  description = "S3 bucket for stack"
  default     = "jdtest-terraform-states"
  # The name of the role file you want to target (no extension)
}
