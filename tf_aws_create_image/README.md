# ep-terraform-modules/tf_aws_create_image

## This contains two different modules.
##
## One to create the Lambda and the IAM role, the other can be called by the user to create the trigger rule for executing the lambda.

### Lambda Function

```
module "create_image_lambda" {
  source            = "git::https://github.dowjones.net/ep-terraform-modules//tf_aws_create_image//lambda" 
  lambda_name             = <name of the lambda function to be created>
  iam_role_arn            = <name of the iam role to be created> 
  allowed_rules_resource  = <the resource filter for the rules that can be created>
}
```

### Trigger rule

```
module "create_image_rule" {
  source            = "git::https://github.dowjones.net/ep-terraform-modules//tf_aws_create_image//rule" 
  rule_name         = <name of rule to create NOTE: rule name MUST start with "djin_newswires_" otherwise it will not be disabled>
  schedule          = <schedule expression for rule e.g. "rate(5 minutes)" or "cron(0 20 * * ? *)">
  statement_id      = <a unique statement of purpose (e.g. ExecFromCloudWatch)>
  instance_name     = <name of instace to backup>
  image_name        = <name of image to create>
  image_description = <description for image>
  disable_rule      = <whether to disable rule after first run> true|false
  web_hook          = <slack web hokk for success message>
}
```
