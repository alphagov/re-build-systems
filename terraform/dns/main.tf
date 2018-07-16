terraform {
  required_version = "= 0.11.7"
}

provider "aws" {
  version = "~> 1.11.0"
  region  = "${var.aws_region}"

  # shared_credentials_file = "~/.aws/credentials"
  profile = "${var.aws_profile}"
}

resource "aws_route53_zone" "primary_zone" {
  name = "${var.team_name}.${var.top_level_domain_name}"

  tags {
    ManagedBy = "terraform"
    Name      = "${var.team_name}.${var.top_level_domain_name}"
    Team      = "${var.team_name}"
  }

  lifecycle {
    prevent_destroy = false
  }
}
