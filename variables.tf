variable "profile" {
  type    = string
  default = "default"
}

variable "region-control" {
  type    = string
  default = "us-east-1"
}

variable "region-nodes" {
  type    = string
  default = "us-east-2"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "nodes-count" {
  type    = number
  default = 4
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}

variable "rhel-east1" {
  type    = string
  default = "ami-0b0af3577fe5e3532"
}

variable "rhel-east2" {
  type    = string
  default = "ami-0ba62214afa52bec7"
}

variable "control_ip" {
  type    = string
  default = "10.0.1.50"
}

variable "node_ips" {
  type = list(string)
  default = [
    "192.168.1.50",
    "192.168.1.51",
    "192.168.1.52",
    "192.168.1.53"
  ]
}

variable "id_rsa" {
  type    = string
  default = "~/terraform/keys/ec2/id_rsa"
}

