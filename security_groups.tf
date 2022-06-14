/*
************************************************************
*                                                          |
*                     Security Groups                      |
*                                                          |
************************************************************
*/


# create security group for 8080/tcp from * and 22/tcp from IP in us-east-1
resource "aws_security_group" "control-sg" {
  provider    = aws.region-control
  name        = "control-sg"
  description = "Allow 22 traffic"
  vpc_id      = aws_vpc.vpc-control.id
  ingress {
    description = "Allow 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow traffic from us-east-2 subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create security group for 22 traffic from IP in us-east-2
resource "aws_security_group" "nodes-sg-ohio" {
  provider = aws.region-nodes
  name     = "nodes-sg-ohio"
  vpc_id   = aws_vpc.vpc-nodes.id
  ingress {
    description = "Allow traffic from us-east-1"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}