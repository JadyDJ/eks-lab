# TF AWS Get State
=============================

This module can be used to get root output from remote iam states stored in artifactory.

Module Input Variables
----------------------

- `subpath` - accountname (e.g - cntsvcnonprod)

The terraform_remote_state data source will **return all of the root outputs** defined in the referenced remote state, an example output might look like:

Usage
--------

```
module "terraform_remote_state" "iam" {
  source              = "git::https://github.dowjones.net/djin-productivity/ep-terraform-modules//tf_aws_get_state//iam"
  subpath         = "cntsvcnonprod"
  }


# Retrieves the iam directly from remote backend state files.

output "iam" {
  value = "${module.terraform_remote_state.iam.sample_iam}"
}
```

where sample_iam is the output in iam workflow (add it to your pr)
