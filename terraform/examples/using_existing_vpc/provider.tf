terraform {
  required_version = "= 0.11.7"

  # Uncomment the next 3 lines if you want to use an existing S3 bucket.
  #  backend "s3" {
  #    encrypt = true
  #  }
}

provider "aws" {
  version = "~> 1.11.0"
  region  = "${var.aws_region}"

  # shared_credentials_file = "~/.aws/credentials"
  profile = "${var.aws_profile}"
}
