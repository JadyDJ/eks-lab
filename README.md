
# Terraform Template for userdata from EP
==========================================

Heavily inspired by Respawn userdata injection

Further details about [chef-max userdata](https://www.terraform.io/docs/providers/template/d/file.html) is available.


Module Input Variables
----------------------

- `chef_cookbook_version` **(Optional)** - Chef cookbook version if you want to pin or `latest` if you want the latest every run.
- `chef_cookbook` - The name of the cookbook that chef-max should pick up.
- `chef_interval` :
  - **(Optional) - for linux**, give a cron for [chef-max interval](https://crontab.guru/)
  - **(Optional) - for windows**, the frequency (in seconds)
    - e.g `1800` for running chef-max every 1800 seconds
    - e.g `0` for not running chef-max again after the first run on instance creation.
  - `chef_interval` is optional and will defaults to no cron/interval when this param is not given.
- `chef_env` - Chef environment that chef-max should target (no .json extension)
- `chef_role` - Chef role that chef-max should target ( no .json extension)

extra for windows:

- `region` = "${var.region}"
- `stack_name` = "${var.stack_name}"
- `stack_id`  = "${var.stack_id}"
- `lc_name` = "${var.lc_name}"


Usage
-----

`Linux`

```js
module "chef-max" {
  source = "git::https://github.dowjones.net/djin-productivity/ep-terraform-modules//tf_aws_userdata"
  chef_role = "test_role"
  chef_env = "chef_env"
  chef_interval = "* * * * *" # optional
  chef_cookbook = "chef_cookbook"
  chef_cookbook_version = "1.0.8" # optional
}

resource "aws_instance" "example" {
      ami           = "sample-ami"
      instance_type = "m3.medium"
      user_data = "${module.chef-max.linux_userdata}"
      subnet_id = "sample-subnet"

      lifecycle {
          create_before_destroy = true
      }
  }

```

`Windows`

```js
module "chef-max" {
  source = "git::https://github.dowjones.net/djin-productivity/ep-terraform-modules//tf_aws_userdata"
  chef_role = "test_role"
  chef_env = "chef_env"
  chef_cookbook = "chef_cookbook"
  chef_interval = "0"  # optional
  region = "${var.region}"
  stack_name = "${var.stack_name}"
  stack_id  = "${var.stack_id}"
  lc_name = "${var.lc_name}"
}

resource "aws_instance" "example" {
      ami           = "sample-ami"
      instance_type = "m3.medium"
      user_data = "${module.chef-max.windows_userdata}"
      subnet_id = "sample-subnet"

      lifecycle {
          create_before_destroy = true
      }
  }

```

- For windows : userdata runs chef-max.txt which downloads chef-max-2012/chef-max-2008 in the instance. This powershell script is bringing in chef-max.ps1/chef-max.bat for manual runs besides creating chef-max service in the instance.

Author
------
Created and maintained by [Kuber Kaul](https://github.dowjones.net/kaulk)
