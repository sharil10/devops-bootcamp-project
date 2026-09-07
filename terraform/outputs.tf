output "web_server_public_ip" {
  description = "Public Elastic IP of the Web Server"
  value       = aws_eip.web_eip.public_ip
}

output "web_server_ssm_command" {
  description = "AWS CLI SSM command to connect to the Web Server"
  value       = "aws ssm start-session --target ${aws_instance.web_server.id}"
}


output "controller_private_ip" {
  description = "Private IP of the Ansible Controller"
  value       = aws_instance.controller.private_ip
}

output "controller_ssm_command" {
  description = "AWS CLI SSM command to connect to the Ansible Controller"
  value       = "aws ssm start-session --target ${aws_instance.controller.id}"
}
output "monitoring_private_ip" {
  description = "Private IP of the Monitoring Server"
  value       = aws_instance.monitoring.private_ip
}

output "monitoring_ssm_command" {
  description = "AWS CLI SSM command to connect to the Monitoring Server"
  value       = "aws ssm start-session --target ${aws_instance.monitoring.id}"
}
