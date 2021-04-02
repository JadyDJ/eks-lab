//
// Module: tf_aws_
//
data "template_file" "linux_userdata" {
  template = "${file("${path.module}/files/linux/chef-max.sh")}"

  vars = {
    chef_role             = "${var.chef_role}"
    chef_env              = "${var.chef_env}"
    chef_interval         = "${var.chef_interval}"
    chef_cookbook         = "${var.chef_cookbook}"
    chef_cookbook_version = "${var.chef_cookbook_version}"
  }
}

data "template_file" "windows_userdata" {
  template = "${file("${path.module}/files/windows/chef-max-userdata.txt")}"

  vars = {
    chef_role             = "${var.chef_role}"
    chef_env              = "${var.chef_env}"
    chef_interval         = "${var.chef_interval}"
    chef_cookbook         = "${var.chef_cookbook}"
    chef_cookbook_version = "${var.chef_cookbook_version == "latest" ? "%5BRELEASE%5D" : var.chef_cookbook_version}"
    region                = "${var.region}"
    stack_name            = "${var.stack_name}"
    stack_id              = "${var.stack_id}"
    lc_name               = "${var.lc_name}"
  }
}
