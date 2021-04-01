# TF AWS Get State
=============================

This module can be used to get root output from remote sg states stored in artifactory.

Module Input Variables
----------------------

- `subpath` - accountname/region (e.g - cntsvcnonprod/virginia)

The terraform_remote_state data source will **return all of the root outputs** defined in the referenced remote state, an example output might look like:

Usage
--------

```
module "terraform_remote_state" "sg" {
  source              = "git::https://github.dowjones.net/djin-productivity/ep-terraform-modules//tf_aws_get_state//sg"
  subpath         = "cntsvcnonprod/virginia"
  }


# Retrieves the sg directly from remote backend state files.

output "fqdn" {
  value = "${module.terraform_remote_state.sg.sample_sg}"
}
```

where sample_sg is the output in sg workflow (add it to your pr)
