# TF AWS Get State
=============================

This module can be used to get root output from remote app states stored in artifactory.

Module Input Variables
----------------------

- `subpath` - githubRepoName/environment/color/region (e.g - djin_abuild_gatekeeper/int/blue/virginia/)

The terraform_remote_state data source will **return all of the root outputs** defined in the referenced remote state, an example output might look like:

Usage
--------

```
module "terraform_remote_state" "stack" {
  source              = "git::https://github.dowjones.net/djin-productivity/ep-terraform-modules//tf_aws_get_state//app"
  subpath         = "djin_acntsvc_sample/stag/blue/virginia"
  }


# Retrieves the fqdn directly from remote backend state files.

output "fqdn" {
  value = "${module.terraform_remote_state.stack.fqdn}"
}
```
where fqdn is the output in app state (the referenced stack needs to expose it as output)
