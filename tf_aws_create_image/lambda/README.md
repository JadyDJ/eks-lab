# ep-terraform-modules/tf_aws_create_image/lambda

## This contains two different modules.
##
## One to create the Lambda and the IAM role, the other can be called by the user to create the trigger rule for executing the lambda.

### The Lambda Function can be created by EP by calling the mdoule as follows:

```
module "create_image_lambda" {
  source                  = "git::https://github.dowjones.net/ep-terraform-modules//tf_aws_create_image//lambda" 
  lambda_name             = <name of the lambda function to be created>
  iam_role_arn            = <name of the iam role to be created> 
  allowed_rules_resource  = <the resource filter for the rules that can be created>
}
```

To make modifications to the lambda function remember to switch to the folder **ep-terraform-modules/tf_aws_create_image/lambda/files/create_images** and run **npm install** and then **npm run package** to replace the zip file to be uloaded to AWS.