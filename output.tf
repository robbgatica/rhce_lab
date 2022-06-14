output "control-node-public-ip" {
  value = aws_instance.control.public_ip
}

output "control-node-host-name" {
  value = aws_instance.control.tags.Name
}
output "managed-nodes-host-names" {
  value = {
    for instance in aws_instance.nodes-ohio :
    instance.id => instance.tags.Name
  }
}