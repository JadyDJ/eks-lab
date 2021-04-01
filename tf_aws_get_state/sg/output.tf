
output "platform_track_alerts_alb_sg" {
  value = "${data.terraform_remote_state.sg.platform_track_alerts_alb_sg}"
}

output "platform_track_alerts_ec2_sg" {
  value = "${data.terraform_remote_state.sg.platform_track_alerts_ec2_sg}"
}
