output "web_server" { value = module.node1.private_ip }
output "controller" { value = module.node2.private_ip }
output "monitoring" { value = module.node3.private_ip }

output "ssm_web_server" {
  description = "SSM command to connect to web server"
  value       = "aws ssm start-session --target ${module.node1.id}"
}

output "ssm_controller" {
  description = "SSM command to connect to controller"
  value       = "aws ssm start-session --target ${module.node2.id}"
}

output "ssm_monitoring" {
  description = "SSM command to connect to monitoring server"
  value       = "aws ssm start-session --target ${module.node3.id}"
}