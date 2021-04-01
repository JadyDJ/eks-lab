#
# Module: tf_aws_userdata
#

output "linux_userdata" {
  value = "${data.template_file.linux_userdata.rendered}"
}

output "windows_userdata" {
  value = "${data.template_file.windows_userdata.rendered}"
}
