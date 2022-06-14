# create key pair for logging into ec2 in us-east-1
resource "aws_key_pair" "control-key" {
  provider   = aws.region-control
  key_name   = "control"
  public_key = file("~/terraform/keys/ec2/id_rsa.pub")
}

# create key pair for logging into ec2 in us-east-2
resource "aws_key_pair" "nodes-key" {
  provider   = aws.region-nodes
  key_name   = "nodes"
  public_key = file("~/terraform/keys/ec2/id_rsa.pub")
}

# Create Ansible control node in us-east-1
resource "aws_instance" "control" {
  provider                    = aws.region-control
  ami                         = var.rhel-east1
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.control-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.control-sg.id]
  subnet_id                   = aws_subnet.subnet_va_1.id
  private_ip                  = var.control_ip

  tags = {
    Name = "ansible_control"
  }

  user_data = templatefile("script.tmpl", { host_id = "ansible_control" })

  depends_on = [aws_main_route_table_association.set-control-default-rt-association]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${var.id_rsa}")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = var.id_rsa
    destination = "/home/ec2-user/id_rsa"
  }

}

# Create managed nodes in us-east-2
resource "aws_instance" "nodes-ohio" {
  provider                    = aws.region-nodes
  count                       = var.nodes-count
  ami                         = var.rhel-east2
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.nodes-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nodes-sg-ohio.id]
  subnet_id                   = aws_subnet.subnet_ohio_1.id
  private_ip                  = var.node_ips[count.index]

  tags = {
    Name = join("", ["ansible", count.index + 1])
  }

  user_data = <<EOF
#!/bin/bash
dnf install -y python39
alternatives --set python /usr/bin/python3
EOF

  depends_on = [aws_main_route_table_association.set-nodes-default-rt-association]

}