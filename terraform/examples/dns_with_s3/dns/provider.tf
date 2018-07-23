terraform {
  required_version = "= 0.11.7"

  # Note that interpolated values cannot be included within the backend block because of the processing sequence that Terraform goes through when initialising.
  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  version = "~> 1.11.0"
  region  = "${var.aws_region}"

  # shared_credentials_file = "~/.aws/credentials"
  profile = "${var.aws_profile}"
}
