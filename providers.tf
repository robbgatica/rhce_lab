# control node: us-east-1, managed nodes: us-east-2
provider "aws" {
  profile = var.profile
  region  = var.region-control
  alias   = "region-control"
}

provider "aws" {
  profile = var.profile
  region  = var.region-nodes
  alias   = "region-nodes"
}