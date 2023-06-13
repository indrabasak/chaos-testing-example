#provider "aws" {
#  profile = "default"
#  alias = "primary"
#  region  = "us-west-2"
#}
#
#provider "aws" {
#  profile = "default"
#  alias = "secondary"
#  region  = "us-east-1"
#}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}
