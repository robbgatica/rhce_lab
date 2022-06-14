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