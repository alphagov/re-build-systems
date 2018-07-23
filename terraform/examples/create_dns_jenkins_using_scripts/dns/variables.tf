# Example file for a customer.

variable "environment" {
  type    = "string"
  default = "test"
}

variable "team_name" {
  type    = "string"
  default = "test9"
}

variable "aws_profile" {
  type    = "string"
  default = "re-build-systems"
}

variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}

# allowed_ips needs to be passed in via .vars file.
# ssh_public_key_file needs to be passed in via .vars file or via command line

