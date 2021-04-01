# ep-terraform-modules/tf_aws_create_image/rule

## Users can call this module as follows:

```
module "create_image_rule" {
  source            = "git::https://github.dowjones.net/ep-terraform-modules//tf_aws_create_image//rule" 
  rule_name         = <name of rule to create NOTE: rule name MUST follow the resource rule specified with the lambda policy otherwise it will not be disabled>
  schedule          = <schedule expression for rule e.g. "rate(5 minutes)" or "cron(0 20 * * ? *)">
  statement_id      = <a unique statement of purpose (e.g. ExecFromCloudWatch)>
  instance_name     = <name of instace to backup>
  image_name        = <name of image to create>
  image_description = <description for image>
  disable_rule      = <whether to disable rule after first run> true|false
  web_hook          = <slack web hokk for success message>
}
```
