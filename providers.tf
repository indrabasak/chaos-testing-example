provider "aws" {
  profile = "default"
  alias = "primary"
  region  = "us-west-2"
}

provider "aws" {
  profile = "default"
  alias = "secondary"
  region  = "us-east-1"
}
